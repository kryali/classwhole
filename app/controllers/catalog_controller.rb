# 
# Description: 
#   Catalog shows information about all the available semesters, subject, courses and sections for a university
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
    @subjectCode = params[:subjectCode]

    @semester = get_semester(params)
    @subject = @semester.subjects.find_by_subjectCode(@subjectCode)
  end

  def get_course(params)
    @courseNumber = params[:courseNumber]

    @subject = get_subject(params)
    @course = @subject.courses.find_by_courseNumber(@courseNumber)
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
  #   courses/:season/:year/:subjectCode
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
  #   courses/:season/:year/:subjectCode/:courseNumber
  def course
    @course = get_course(params)
    @sections = @course.sections
    render 'course'
  end


end
