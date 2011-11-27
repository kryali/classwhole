class SchedulerController < ApplicationController
  before_filter :set_cache_buster
  include ApplicationHelper

  def index
  end
    
  def show
    @user = User.find( params["id"].to_i )
    @sections = @user.schedule
    @hide_buttons = true
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
        logger.error current_user.courses
        redirect_to "/500.html"
      end
      scheduler.valid_schedules
    }
    @course_ids = course_ids.to_json
    # Restricting to smaller number of schedules, until new method implemented
    # Show twenty max. The less schedules the algo gives them, then the better we're doing
    @possible_schedules = all_possible_schedules[0..60]
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

  def sidebar
    sections = []
    params["schedule"].each do |section_id|
      sections << Section.find_by_id(section_id.to_i)
    end
    render :partial => "course_sidebar", :locals => { :sections => sections}
  end

  # Route that delivers section hints via AJAX
  def move_section
    schedule = []
    params["schedule"].each do |section_id|
      schedule << Section.find_by_id(section_id.to_i)
    end
    section_hints = []
    if params["section"]
      section = Section.find(params["section"].to_i)
      course = Register_Course.new(section.course)
      # HACK, this kept dying when trying to move DANC 100
      if course.configurations_hash[section.configuration_key]
        section_hints = course.configurations_hash[section.configuration_key][section.section_type]
      end
      section_hints.delete_if{|move| move.schedule_conflict?(schedule)}
    end

    # Nothing needs to be rendered
    # params["render"] forces the render (used for dragndrop render)
    if section_hints.empty? and not params["render"]
      render :json => { :status => "error", :message => "no hints for section" }
      return
    end

    start_hour, end_hour = Section.hour_range( schedule )

    render :json => { :section_hints => section_hints, 
                      :schedule => schedule, 
                      :start_hour => start_hour,
                      :end_hour => end_hour }
    # render :partial => 'section_ajax', :layout => false
  end

  def save
    if current_user.is_temp?
      render :json => {
                        :status => "error", 
                        :message => "Log in to save schedule."
                      }
    else
      current_user.add_schedule( params["schedule"] )
      render :json => {
                        :status => "success", 
                        :message => "Schedule saved.",
                        :redirect_url => scheduler_show_path(current_user.id)
                      }
    end
  end

  
  # @desc: This function returns an 
  #        AJAX repsonse of what the user should post to facebook
  #
  def share
    if current_user.is_temp?
      render :json => {
                        :status => "error", 
                        :message => "Log in to save schedule."
                      }
    else
      # Save the schedule so they can link to it
      current_user.add_schedule( params["schedule"] )
      course_string = ""
      for course in current_user.courses
        course_string += course.to_s + " - " + course.title + ", "
      end

      show_path = scheduler_show_path(current_user.id)
      show_path.slice!(0) # Get rid of the leading slash because root_url gives it to us
      link_url = root_url + show_path
      render :json => {
        :status => "success",
        :options => {
          :method => 'feed',
          :name => "#{current_user.name}'s Schedule",
          :link => link_url,
          :source => 'http://i.imgur.com/0Ei7C.jpg',
          :caption => 'Checkout my schedule!',
          :description => course_string
        }
      }
    end
  end

  def register
    if !params["crns"]
      render :text => "code broke"
      return
    else
      @crns = params["crns"].split(",")
    end
  end

#  require 'base64'
  def download
    # we are a PNG image
    response.headers["Content-Type"] = "image/png"
    response.headers["Content-Disposition"] = "attachment; filename=\"schedule.png\""
     
    #capture, replace any spaces w/ plusses, and decode
    encoded = params["image_data"]
    encoded.gsub!(/[ ]/, ' ' => '+')
    decoded = Base64.decode64(encoded)
     
    #write decoded data
    render :text => decoded
  end

end
