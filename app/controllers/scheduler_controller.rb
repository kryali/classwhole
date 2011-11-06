class SchedulerController < ApplicationController
 before_filter :set_cache_buster
 helper_method :cookie_class_list
 include ApplicationHelper

  def index
  end
    
  def show
  end

  def new
    if current_user    
      scheduler = Scheduler.new(current_user.courses)
    else
			course_id_list = []
      course_list = []
      course_id_list = cookies["classes"].split('|')
			for id in course_id_list
				course_list << Course.find(id)
			end      
			scheduler = Scheduler.new(course_list)
    end    
    scheduler.schedule_courses
    @possible_schedules = scheduler.valid_schedules[0,5]
    render 'show'
  end

  def move_section

    schedule = []
    params["schedule"].each do |section_id|
      schedule << Section.find_by_id(section_id.to_i)
    end

    if params["section"]
      section = Section.find(params["section"].to_i)
      course = Register_Course.new(section.course)
      @section_hints = course.configurations_hash[section.configuration_key][section.section_type]
      @section_hints.delete_if{|move| move.schedule_conflict?(schedule)}
    end
    @schedule = schedule

    render :partial => 'section_ajax', :layout => false
  end

  def save
    schedule = Schedule.new
    current_user.schedule = schedule
    Schedule.transaction do
      schedule.user = current_user
      params["schedule"].each do |section_id|
        schedule.sections << Section.find_by_id(section_id.to_i)
      end
    end
    schedule.save
    render :text => "fuck."
  end

end
