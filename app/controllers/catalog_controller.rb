# 
# Description: 
#   Catalog shows information about all the available semesters, subject, courses and sections for a university
#
# TODO: Too many queries right now, (i.e we look up semester for every single one). Need to find a better way, maybe pass along the object?
#
class CatalogController < ApplicationController
  

  # <helpers> 
  # Description:
  #  The following 3 functions parse paramaters to find the database object
  #
  def get_semester(params)
    @year = params[:year]
    @season = params[:season] 
    @semester = Semester.find_by_year_and_season(@year, @season)  
	end

  def get_subject(params)
    @semester = get_semester(params)
    @subject_code = params[:subject_code] 
    @subject = @semester.subjects.find_by_code(@subject_code)
  end

  def get_course(params)
    @subject = get_subject(params)
    @course_number = params[:course_number] 
    @course = @subject.courses.find_by_number(@course_number)
  end
  # </helpers>

  # Description:
  # - Display university information
  # - Show the available semesters
  # 
  # Route:
  #   courses/
  def index
    @semesters = Semester.all   
		render 'index'
  end

  # Description:
  # - Display semeseter information
  # - Show the subjects for the given semester
  # 
  # Route:
  #   courses/:season/:year 
  def semester
    @semester = get_semester(params)
    @subjects = @semester.subjects
		render 'semester'
  end

  # Description:
  # - Display subject information
  # - Show all the courses for a given subject
  #
  # Route:
  #   courses/:season/:year/:subject_code
  def subject
    @subject = get_subject(params)
    @courses = @subject.courses
		render 'subject'
  end

  # Description:
  # - Display course information
  # - Show all the sections for a given course
  #
  # Route:
  #   courses/:season/:year/:subject_code/:courseNumber
  def course
    @course = get_course(params)
    @sections = @course.sections     
		@types_of_sections = get_different_sections()
		render 'course'
  end

	# Description:
	#   -Figure out the various types of sections for a course
	#   - (lecture, discussion, etc)
	#	  - used to make the tabs for the sections table on course page
	#
	def get_different_sections()	
		lecture_exists = 0		
		list = []
		lecture_index = -1
		lecture_discussion_index = -1		
		index = 0
		for section in @sections do
			if !list.include? section.section_type
				list << section.section_type			
				if section.section_type == 'LEC'
					lecture_index = index			
				end
				if section.section_type == 'LCD'
					lecture_discussion_index = index				
				end
				index = index + 1				
			end		
		end		
		# This code puts Lecture and Lecture-Discussions at the front of the list 		
		if lecture_index != -1
			lecture_exists = 1			
			temp = list[0]
			list[0] = list[lecture_index]
			list[lecture_index] = temp
		end
		if lecture_discussion_index != -1
			if lecture_exists != 1
				temp = list[0]
				list[0] = list[lecture_discussion_index]
				list[lecture_discussion_index] = temp
			end			
		end
		return list
	end

 	

  # Description:
  # - Return a json formatted list of classes for autocomplete
  #
  # Route:
  #   courses/search/auto/subject/:subject_code
  def course_auto_search
    result_json = Course.trie(params["term"])
    if result_json
      render :json => result_json 
      return
    end

    # If result_json is nil, then we couldn't connect to redis
    unless result_json
      # NOTE: this section likely belongs in the model as a function self.backup_search(params)
      #       couldn't figure it out
      course_list = []

      # Fall back to using all courses, if we can't find the subject
      begin
        courses = Subject.find_by_code(params[:subject_code]).courses
      rescue
        courses = all_courses
      end

      courses.each do |course|
        if params["term"] and course.to_s.include?(params["term"].upcase) or not params["term"]
          course_list << { label: "#{course.to_s}",
                           title: "#{course.title}",
                           value: "#{course.to_s}" }
        end
      end
      render :json => course_list
    end
  end

  # Description:
  # - Return a json formatted list of subjects for autocomplete
  #
  # Route:
  #   courses/search/auto/subject
  def subject_auto_search
    result_json = Subject.trie(params["term"])
    if result_json
      render :json => result_json 
      return
    end
    
    # If result_json is nil, then we couldn't connect to redis
    unless result_json
      # NOTE: this section likely belongs in the model as a function self.backup_search(params)
      #       couldn't figure it out
      subject_list = []
      all_subjects.each do |subject|
        if params["term"] and subject.starts_with?(params["term"].upcase) or not params["term"]
          subject_list << { label: "#{subject.to_s}",
                            title: "#{subject.title}",
                            value: "#{subject.code}" }
        end
      end

      render :json => subject_list 
    end
  end

  def simple_search
    render :json => Course.trie(params[:term])
  end

  def all_subjects
		@all_subjects ||= Subject.all
  end

	def all_courses
		@all_courses ||= Course.all
	end

end
