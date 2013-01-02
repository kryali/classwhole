class SchedulerController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :set_cache_buster
  include ApplicationHelper
  include SchedulerHelper

  def show
    #@user = User.find( params["id"].to_i )
    @user = User.find_by_fb_id( params["id"].to_i )
    @sections = @user.schedule
    @hide_buttons = true
  end

  def new
    @configurations = Scheduler.get_configurations( current_user.courses )

    begin
      # Don't take longer than 20 seconds to retrieve & parse an RSS feed
      Timeout::timeout(25) do
        @schedule = Scheduler.initial_schedule(current_user.courses)
      end
    rescue Timeout::Error
      logger.error "SCHEDULE TIMEOUT"
      logger.error current_user.courses.inspect
      redirect_to "/500.html"
      return
    end
  end

  def change_configuration
    logger.error params.inspect
    course = Course.find(params["course_id"])
    configuration = course.configurations.find_by_key(params["new_config_key"])
    old_schedule = []
    unless params["ids"].nil?
      params["ids"].each do |id|
        old_schedule << Section.find(id)
      end
    end
    schedule = Scheduler.schedule_change( old_schedule, configuration )
    schedule.map { |section| Scheduler.build_section section }
    start_hour, end_hour = Section.hour_range( schedule )
    render :json => { :schedule => schedule, :start_hour => start_hour, :end_hour => end_hour }
  end

  # Route that delivers section hints via AJAX
  def move_section
    schedule = []
    params["schedule"].each do |section_id|
      section = Section.find_by_id(section_id.to_i)
      Scheduler.build_section( section )
      schedule << section
    end
    section_hints = []
    if params["section"]
      section = Section.find(params["section"].to_i)
      section_hints = section.configuration.sections_hash[section.short_type]
      section_hints.delete_if{|move| move.schedule_conflict?(schedule)}

      # Have to give the client all the data about the section, which spans multiple tables
      section_hints.map do |section_hint| 
        Scheduler.build_section( section_hint )
      end
    end

    # Nothing needs to be rendered
    # params["render"] forces the render (used for dragndrop render)
    if section_hints.empty? and not params["render"]
      render :json => { :status => "error", :message => "no hints for section" }
      return
    end

    start_hour, end_hour = Section.hour_range( schedule )

    render :json => { 
                      :section_hints => section_hints,
                      :schedule => schedule,
                      :start_hour => start_hour,
                      :end_hour => end_hour
                    }
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
          :source => 'http://i.imgur.com/oMRcn.png',
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


  #
  # Route for realtime scheduling
  #
  def index
    # need this function called before we can use it, p weird
    current_user
    begin
      # Don't take longer than 20 seconds to retrieve & parse an RSS feed
      Timeout::timeout(5) do
        @schedule = Scheduler.initial_schedule(current_user.courses)
        @configurations = Scheduler.get_configurations( current_user.courses )
      end
      @schedule_json = Scheduler.pkg(current_user.courses, @schedule).to_json
    rescue Timeout::Error
      # If we got a timeout, then that means that the user has a configuration of bad courses
      #current_user.courses = [] if current_user
    end
  end

  def icalendar
    sections = []
    params["schedule"].split(",").each do |section_id|
      begin
        sections << Section.find( section_id.to_i )
      rescue ActiveRecord::RecordNotFound
        render :json => { :status => :error }
        return
      end
    end
    cal = Icalendar::Calendar.new
    sections.each do |section|
      section.meetings.each do |meeting|
        unless section.start_date.nil? or meeting.start_time.nil? or meeting.end_time.nil?
          d = section.start_date
          s = meeting.start_time
          e = meeting.end_time
          sdt = DateTime.new(d.year, d.month, d.day, s.hour, s.min, s.sec)
          edt = DateTime.new(d.year, d.month, d.day, e.hour, e.min, e.sec)
          udt = section.end_date
          meeting.days.split("").each do |day|
            case day
            when "M"
              wday = 1
            when "T"
              wday = 2
            when "W"
              wday = 3
            when "R"
              wday = 4
            when "F"
              wday = 5
            else
              wday = 6
            end
            offset = wday - sdt.wday
            event = cal.event
            event.dtstart = sdt+offset
            event.dtend = edt+offset
            event.recurrence_rules = ["FREQ=WEEKLY;UNTIL=#{(udt+offset).strftime("%Y%m%dT%H%M%S")}"]
            event.summary = "#{section.course_subject_code} #{section.course_number} - #{section.section_type}"
            event.description = "#{section.course.title} - #{section.course.description}"
            event.location = meeting.building
          end
        end
      end
    end
    response.headers["Content-Type"] = "text/calendar"
    response.headers["Content-Disposition"] = "attachment; filename=\"ClasswholeSchedule.ics\""
    
    render :text => cal.to_ical
  end

  #
  # Description: This function gets passed a list of course ids and adds it
  #   to the currently logged in user 
  #
  # We should probably be looking up the id instead of doing a slow search here
  #
  def add_course
    current_user
    # If the person isn't logged into facebook, create a cookie, but don't overwrite it
    if cookies["classes"].nil? and current_user.is_temp?
      cookies["classes"] = {:value => "", :expires => 1.day.from_now}
    end

    course_id = params["id"].to_i
    course = Course.find(course_id)
    
    if current_user.courses.include?(course) 
      render :json => { :success => false, :status => "error", :message => "Class already added" }
      return
    else
      courses_copy = current_user.courses.clone 
      courses_copy << course
      begin
        # Don't take longer than 5 seconds to retrieve & parse an RSS feed
        Timeout::timeout(5) do
          @schedule = Scheduler.initial_schedule(courses_copy)
          current_user.add_course(course) unless @schedule.empty?
        end
      rescue Timeout::Error
        render :json => { :success => false, :status => "error", :message => "schedule timeout.. possible conflict?" }
        return
      end

      if @schedule.empty?
        render :json => {:success => false, :status => "error", :message => "Sorry, there was a conflict"} 
      else
        render :json => {:success => true}
      end
    
    end
  end


  #
  # Description: This function gets passed a course ids and removes the course
  #   from the currently logged in user 
  #
  def remove_course
    course = Course.find(params["id"].to_i)
    current_user.rem_course( course )
    current_user.courses.delete( course )
    render :json => {:status => :success}
=begin
    @schedule = Scheduler.initial_schedule(current_user.courses)
  
    # Prepare the schedule for json delivery
    Scheduler.pack_schedule( @schedule )
    start_hour, end_hour = Section.hour_range( @schedule )

    render :json => { 
                      :status => "success", 
                      :message => "Class removed", 
                      :schedule => @schedule,
                      :start_hour => start_hour,
                      :end_hour => end_hour,
                    }
    return
=end
  end

  def schedule
    @schedule = Scheduler.initial_schedule(current_user.courses) unless @schedule
    render :json => Scheduler.pkg(current_user.courses, @schedule)
  end
end
