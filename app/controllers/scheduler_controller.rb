class SchedulerController < ApplicationController
  before_filter :set_cache_buster
  include ApplicationHelper

  def index
  end
    
  def show
    #@user = User.find( params["id"].to_i )
    @user = User.find_by_fb_id( params["id"].to_i )
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
      #[Scheduler.initial_schedule(current_user.courses)]
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

  # prepares a section object for json
  def build_section( section )
    meetings = []
    section.meetings.each do |meeting|    
        #meeting["instructors"] = meeting.instructors[0]
        meetings << meeting
    end
    section['short_type'] = section.short_type_s
    section['meetings'] = meetings
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
          event.location = meeting.building.name
        end
      end
    end
    response.headers["Content-Type"] = "text/calendar"
    response.headers["Content-Disposition"] = "attachment; filename=\"ClasswholeSchedule.ics\""
    
    render :text => cal.to_ical
  end
end
