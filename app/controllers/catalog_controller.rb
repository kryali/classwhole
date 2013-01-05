# 
# Description: 
#   Catalog shows information about all the available semesters, subject, courses and sections for a university
#
# TODO: Too many queries right now, (i.e we look up semester for every single one). Need to find a better way, maybe pass along the object?
#
class CatalogController < ApplicationController
  include ApplicationHelper  
  #caches_page :semester, :subject, :course

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
    get_semester(params)
    @subject_code = params[:subject_code]
    return if @semester.nil?
    @subject = @semester.subjects.find_by_code(@subject_code)
  end

  def get_course(params)
    get_subject(params)
    @course_number = params[:course_number]
    return if @subject.nil?
    @course = @subject.courses.find_by_number(@course_number)
  end


  # gets the indeces to jump to for the pagination
  # neccesary because the header covers ~2em

  def get_pagination_indeces(semester)
    counter = 0
    ret_list = []
    first_letter = -1
    for sub in semester.subjects
      if first_letter != sub.code[0]
        inside_array = []
        first_letter = sub.code[0]
        inside_array << counter
        inside_array << sub.code[0]        
        ret_list << inside_array
      end      
      counter+=1
    end
    ret_list << -1
    return ret_list
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
    get_semester(params)
    if @semester.nil?
      redirect_to show_semester_path( $CURRENT_SEMESTER.season, $CURRENT_SEMESTER.year )
      return
    end
    @subjects = @semester.subjects
    @pagination_indeces = get_pagination_indeces(@semester)
		render 'semester'
  end

  # Description:
  # - Display subject information
  # - Show all the courses for a given subject
  #
  # Route:
  #   courses/:season/:year/:subject_code
  def subject
    get_subject(params)
    if @subject.nil?
      all_semesters = Semester.all
      (all_semesters.size..1).each do |i|
        semester = all_semesters[i-1]
        semester_subjects = semester.subjects.find_by_code( params[:subject_code] )
        next if semester_subjects.nil?
        redirect_to show_subject_path( semester.season, semester.year, params[:subject_code] )
        return
      end
      redirect_to "/"
      return
    end
    @courses = @subject.courses
		render 'subject'
  end

  # Description:
  # - Display course information
  # - Show all the sections for a given course
  #
  # Route:
  #   courses/:season/:year/:subject_code/:course_number
  def course
    get_course(params)
    if @course.nil?
      all_semesters = Semester.all
      (all_semesters.size..1).each do |i|
        semester = all_semesters[i-1]
        semester_subjects = semester.subjects.find_by_code( params[:subject_code] )
        next if semester_subjects.nil?
        course = semester_subjects.courses.find_by_number( params[:course_number] )
        next if course.nil?

        redirect_to show_course_path( semester.season, semester.year, params[:subject_code], params[:course_number] )
        return
      end
      redirect_to "/"
      return
    end
    @sections = @course.sections
    @meetings  = []
    for section in @sections
      for meeting in section.meetings      
        @meetings << meeting
      end
    end     
		@types_of_sections = get_different_sections()
    course_ids = []
    course_list = []
    course_list << @course
    course_ids << @course.id
    @schedule = Scheduler.initial_schedule(course_list)
#    for sec in @course.sections
#      @schedule << sec
#    end
    @course_ids = course_ids.to_json
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
				if section.section_type == 'lecture'
					lecture_index = index			
				end
				if section.section_type == 'lecture-discussion'
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
          course_list << { :label => "#{course.to_s}",
                           :title =>  "#{course.title}",
                           :value => "#{course.to_s}" }
        end
      end
      render :json => course_list
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

  def sections 
    sections = []
    params["schedule"].each do |section_id|
      begin
        sections << Scheduler.pkg_section(Section.find(section_id.to_i))
      rescue ActiveRecord::RecordNotFound
        render :json => { :status => :error }
        return
      end
    end
    render :json => { :status => :success, :sections => sections }
  end

  def get_subjects
    render :json => Subject.minify($CURRENT_SEMESTER.subjects)
  end

  def get_courses
    subject = $CURRENT_SEMESTER.subjects.find_by_code(params[:subject_code].upcase)
    if subject
      render :json => subject.mini_courses 
    else
      render :json => { success: false, message: "Subject #{params[:subject_code]} not found" } 
    end
  end
end
