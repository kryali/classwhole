class SchedulerController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :set_cache_buster
  include ApplicationHelper
  include SchedulerHelper

  def show
    @user = User.find_by_fb_id(params["id"].to_i)
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
    schedule.map { |section| Scheduler.pkg_section(section) }
    start_hour, end_hour = Section.hour_range( schedule )
    render :json => { :schedule => schedule, :start_hour => start_hour, :end_hour => end_hour }
  end

  def section_hints
    section_hints = []
    section = Section.find(params["id"].to_i)
    section_hints = section.configuration.sections_hash[section.short_type]
    section_hints.delete_if{|move| move.schedule_conflict?(current_user.schedule)}

    # Have to give the client all the data about the section, which spans multiple tables
    section_hints = section_hints.map {|section_hint| Scheduler.pkg_section(section_hint)}

    if section_hints.empty?
      render :json => {:success => false, :status => "error", :message => "No sections"}
      return
    end

    render :json => {:success => true, :section_hints => section_hints}
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

  def index
  end

  def icalendar
    sections = []
    params["schedule"].split(",").each do |section_id|
      begin
        sections << Section.find(section_id.to_i)
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

  def add_course
    course = Course.find(params["id"].to_i)
    
    if current_user.courses.include?(course) 
      render :json => {:success => false, :status => "error", :message => "Class already added"}
      return
    end

    courses_copy = current_user.courses.clone 
    courses_copy << course
    schedule = do_schedule(courses_copy)
    if schedule.nil? or schedule.empty?
      render :json => {:success => false, :status => "error", :message => "Sorry, there was a conflict."}
      return
    end
    current_user.add_course(course)
    current_user.schedule = schedule
    render :json => {:success => true}
  end

  def remove_course
    course = Course.find(params["id"].to_i)
    current_user.rem_course(course)

    sections_to_remove = current_user.schedule.select {|section| section.course_id == course.id}
    sections_to_remove.each {|section| current_user.schedule.delete(section)}
    current_user.save if current_user.is_temp?

    render :json => {:status => :success}
  end

  def replace
    current_user.schedule.delete(Section.find(params[:del_id].to_i))
    current_user.schedule << Section.find(params[:add_id].to_i)
    current_user.save
    render :json => {:status => :success}
  end

  def schedule
    user = params[:id] ? User.find(params[:id].to_i) : current_user
    render :json => Scheduler.pkg(user.courses, user.schedule)
  end

  private
  def do_schedule(courses)
    begin
      Timeout::timeout(5) {schedule = Scheduler.initial_schedule(courses)}
    rescue Timeout::Error
      return nil
    end
  end
end
