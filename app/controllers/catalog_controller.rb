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
    render 'course'
  end

  # Description:
  # - Return a json formatted list of classes for autocomplete
  #
  # Route:
  #   courses/class_list
  def auto_search
    class_list = []
    Course.all.each do |course|
      if course.to_s.include?(params["term"].upcase)
        class_list << { label: "#{course.to_s}",
                        title: "#{course.title}",
                        value: "#{course.id}" }
      end
    end
    render :json => class_list
  end
end
