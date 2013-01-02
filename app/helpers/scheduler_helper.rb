module SchedulerHelper
  @schedule_block_height = 50

  def print_day(day_short_code)
    case day_short_code
    when "M"
      return "Mon"
    when "T"
      return "Tue"
    when "W"
      return "Wed"
    when "R"
      return "Thu"
    when "F"
      return "Fri"
    else
      return "nil"
    end
  end

  def print_hour(hour)
    if( hour > 12 and hour < 24)
      return "#{hour-12}"
    elsif ( hour < 12 and hour != 0)
      return "#{hour}"
    elsif ( hour == 24 )
      return "#{hour-12}"
    elsif ( hour == 12 )
      return "#{hour}"
    end
    return "nil"
  end

  def section_colors( sections )
    courses = []
    sections.each {|section| courses << section.course_id unless courses.include?(section.course_id)}
    courses.sort!

    colors = Hash.new
    colors_current = 0
    courses.each do |course|
        colors[course] = "color-#{colors_current}"
        colors_current += 1 
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

  def day_header_arr
    ["Mon", "Tue", "Wed", "Thu", "Fri"]
  end
end
