class SchedulerController < ApplicationController
 before_filter :set_cache_buster
  def index
  end
    
  def show
  end

  def new
    scheduler = Scheduler.new(current_user.courses)
    scheduler.schedule_courses
    @possible_schedules = scheduler.valid_schedules[0,5]
    render 'show'
  end

  def move_section
    logger.info "Section: #{params["section"]}"

    schedule = []
    params["schedule"].each do |section_id|
      schedule << Section.find(section_id.to_i)
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
end
