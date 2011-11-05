class SchedulerController < ApplicationController
 before_filter :set_cache_buster
  def index
  end
    
  def show
    all_possible_schedules = Rails.cache.fetch( :courses => current_user.courses,   
                                                :data => 'valid_schedules' ) {
      scheduler = Scheduler.new(current_user.courses)
      scheduler.schedule_courses
      scheduler.valid_schedules
    }
    @possible_schedules = all_possible_schedules
  end

  def new
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
