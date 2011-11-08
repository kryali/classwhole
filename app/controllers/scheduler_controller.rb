class SchedulerController < ApplicationController
  before_filter :set_cache_buster
  include ApplicationHelper

  def index
  end
    
  def show
    @user = User.find( params["id"].to_i )
    @sections = @user.schedule
  end

  def new
    course_ids = []
    current_user.courses.each do |course|
      course_ids << course.id
    end
    all_possible_schedules = Rails.cache.fetch( :courses => course_ids,   
                                                :data => 'valid_schedules' ) {

      begin      
      scheduler = Scheduler.new(current_user.courses)
      status = Timeout::timeout(5) {     
        scheduler.schedule_courses
      } 
      rescue Timeout::Error
        redirect_to "/500.html"
      end
      scheduler.valid_schedules
    }
    @course_ids = course_ids.to_json
    @possible_schedules = all_possible_schedules
    #@possible_schedules = all_possible_schedules[0..5]
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
      #logger.info "Why is this happening...." # This usually shouldn't happen
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
  end

  def move_section
    schedule = []
    params["schedule"].each do |section_id|
      schedule << Section.find_by_id(section_id.to_i)
    end
    @section_hints = []
    if params["section"]
      section = Section.find(params["section"].to_i)
      course = Register_Course.new(section.course)
      @section_hints = course.configurations_hash[section.configuration_key][section.section_type]
      @section_hints.delete_if{|move| move.schedule_conflict?(schedule)}
    end
    @schedule = schedule

    # Nothing needs to be rendered
    # params["render"] forces the render (used for dragndrop render)
    if @section_hints.empty? and not params["render"]
      render :json => { :status => "error", :message => "no hints for section" }
      return
    end

    render :partial => 'section_ajax', :layout => false
  end

  def save
    if current_user.is_temp?
      render :json => {:status => "error", :message => "Log in to save schedule."}
    else
      redis_key  ="user:#{current_user.id}:schedule"
      $redis.del(redis_key)
      params["schedule"].each do |section_id|
        $redis.sadd(redis_key, section_id.to_i)
      end
      render :json => {:status => "success", :message => "Schedule saved."}
    end
  end

end
