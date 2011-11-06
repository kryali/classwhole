class SchedulerController < ApplicationController
 before_filter :set_cache_buster
  def index
  end
    
  def show
    course_ids = []
    current_user.courses.each do |course|
      course_ids << course.id
    end
    all_possible_schedules = Rails.cache.fetch( :courses => course_ids,   
                                                :data => 'valid_schedules' ) {
      scheduler = Scheduler.new(current_user.courses)
      scheduler.schedule_courses
      scheduler.valid_schedules
    }
    @course_ids = course_ids.to_json
    #@possible_schedules = all_possible_schedules[0..5]
    @possible_schedules = all_possible_schedules
  end

  def new
  end

  def paginate
    range_start = params["start"].to_i
    @range_end = params["end"].to_i
    course_ids = params["courses"]
    course_ids.size.times do |i|
      course_ids[i] = course_ids[i].to_i
    end

    all_possible_schedules = Rails.cache.fetch( :courses => course_ids,   
                                                :data => 'valid_schedules' ) {
      logger.info "Why is this happening...." # This usually shouldn't happen
      courses = []
      course_ids.each do | course_id |
        courses << Course.find( course_id.to_i )
      end
      scheduler = Scheduler.new(courses)
      scheduler.schedule_courses
      scheduler.valid_schedules
    }
    @possible_schedules = all_possible_schedules[range_start..@range_end]
    render "paginate", :layout => false
    #render :json => @possible_schedules
    #@possible_schedules = all_possible_schedules[0...5]
    #render :json => { success: true, courses: params["courses"], start: params["start"], end: params["end"] }
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
