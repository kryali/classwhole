# Responsible for business-logic of courses functionality
class CoursesController < ApplicationController

  # Index page of the main course view
  def index
    @subjects = Subject.all
  end

  # Subject specific page (Major) 
  # match 'courses/:subjectCode' => 'courses#subject' 
  def subject
    @subject = Subject.find(params[:subjectCode])
  end

  # Class specific page
  # match 'courses/:subjectCode/:courseNumber' => 'courses#course'
  def course
    @subject = Subject.find(params[:subjectCode])
    @course = Course.find(params[:courseNumber])
  end

  # Section specific page
  # inc: Discussions and Lecture sections
  # match 'courses/:subjectCode/:courseNumber/:sectionId' => 'courses#section'
  def section
    @subject = Subject.find(params[:subjectCode])
    @course = Course.find(params[:courseNumber])
    @section = Section.find(params[:sectionId])
  end

end_)
