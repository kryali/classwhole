module SchedulerHelper
  @schedule_block_height = 50

  def print_day(day_short_code)
    case day_short_code
    when "M"
      return "Monday"
    when "T"
      return "Tuesday"
    when "W"
      return "Wednesday"
    when "R"
      return "Thursday"
    when "F"
      return "Friday"
    else
      return "nil"
    end
  end

  def print_hour(hour)
    if( hour > 12 and hour < 24)
      return "#{hour-12} pm"
    elsif ( hour < 12 and hour != 0)
      return "#{hour} am"
    elsif ( hour == 24 )
      return "#{hour-12} am"
    elsif ( hour == 12 )
      return "#{hour} pm"
    end
    return "nil"
  end

  def hour_range(sections)

    finished_courses = []
    all_possible_sections = []
    sections.each do |section|

      course = section.course
      next if finished_courses.include?(course.id)

      # Build up a list of all possible sections for the course
      course.sections.each do |course_section|
        # Add it if we don't already have the section
        if !all_possible_sections.include?(course_section)
          all_possible_sections << course_section
        end
      end

      # Mark the course as already processed so we dont do it again
      finished_courses << course.id
    end

    earliest_start_hour = 24 * 60
    latest_end_time = 0
    
    all_possible_sections.each do |section|
      section.meetings.each do |meeting|
        next if !meeting.start_time
        current_start_time = meeting.start_time.hour * 60 + meeting.start_time.min
        current_end_time = meeting.end_time.hour * 60 + meeting.end_time.min

        if current_start_time < earliest_start_hour
          earliest_start_hour = current_start_time
        end
        if current_end_time > latest_end_time
          latest_end_time = current_end_time
        end
      end
    end

    earliest_start_hour = (earliest_start_hour.to_f/60).ceil
    latest_end_hour = (latest_end_time.to_f/60).ceil
    return earliest_start_hour, latest_end_hour
  end

  def meetings_by_days(sections)
    meetings_by_days = Hash.new
    ["M","T","W","R","F"].each {|day| meetings_by_days[day] = Array.new }

    sections.each do |section|
      section.meetings.each do |meeting|
        next if not meeting.days
        days = meeting.days.split("")
        days.each { |day| meetings_by_days[day].push(meeting) if meetings_by_days.has_key?(day) }
      end
    end

    return  meetings_by_days
  end

  def meeting_top_px( meeting, start_hour )
    top_px = (meeting.start_time.hour - start_hour + (meeting.start_time.min/60.0)) * 48 # scheduler_block_height
    return top_px
  end

  def meeting_height_px( meeting )
    return meeting.duration * 48#@scheduler_block_height
  end

  def section_colors( sections )
    colors = Hash.new
    colors_current = 0
    sections.sort!
    sections.each do |section|
      unless colors.has_key?(section.course_id)
        colors[section.course_id] = "color-#{colors_current}"
        colors_current += 1 
      end
    end
    return colors 
  end

  # Remove online and arranged sections
  def remove_onl_sections( sections )

    onl_sections = []
    sections.each do |section|
      section.meetings.each do |meeting|
        onl_sections << section if meeting.start_time.nil? # MIGHT ADD DUPLICATES
      end
    end

    onl_sections.each do |onl_section|
      sections.delete(onl_section)
    end

    return onl_sections
  end

  def shorten(text, length, end_string = '...')
    return text if( text.length <= length )
    letters = text.split("")
    return letters[0..(length-1)].join + end_string
  end

  def mini_meeting_top_px( meeting )
    top_px = (meeting.start_time.hour - 7 + (meeting.start_time.min/60.0)) * 6
    return top_px
  end

  def mini_meeting_height_px( meeting )
    return meeting.duration * 6
  end

  def courses_from_sections( sections )
    courses = []
    course_section_hash = {}
    sections.each do |section|
      course = section.course
      courses << section.course if !courses.include?(section.course)
      course_section_hash[course.id] ||= []
      course_section_hash[course.id] << section
    end
    return courses, course_section_hash
  end

  # This function takes an array of section array of ActiveRecord 
  # objects spits out the sections in ids in an array
  def section_ids_from_schedules( all_schedules )
    logger.info(all_schedules.inspect)
    schedules = []
    all_schedules.each do |sections|
      section_ids = []
      sections.each do |section|
        section_ids << section.id
      end
      schedules.push( section_ids )
    end
    return schedules
  end

end
