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
      next if !section.start_time
      current_start_time = section.start_time.hour * 60 + section.start_time.min
      current_end_time = section.end_time.hour * 60 + section.end_time.min

      if current_start_time < earliest_start_hour
        earliest_start_hour = current_start_time
      end
      if current_end_time > latest_end_time
        latest_end_time = current_end_time
      end
    end

    earliest_start_hour = (earliest_start_hour.to_f/60).ceil
    latest_end_hour = (latest_end_time.to_f/60).ceil
    return earliest_start_hour, latest_end_hour
  end

  def sections_by_days(sections)
    sections_by_days = Hash.new
    ["M","T","W","R","F"].each do |day|
      sections_by_days[day] = Array.new
    end

    sections.each do |section|
      next if not section.days
      days = section.days.split("")
      days.each do |day|
        sections_by_days[day].push(section)
      end
    end

    return  sections_by_days
  end

  def section_top_px( section, start_hour )
    top_px = (section.start_time.hour - start_hour + (section.start_time.min/60.0)) * 60 # scheduler_block_height
    return top_px
  end

  def section_height_px( section )
    return section.duration * 60#@scheduler_block_height
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
      onl_sections << section if section.start_time.nil?
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

  def mini_section_top_px( section )
    logger.info "TOP: #{section}"
    top_px = (section.start_time.hour - 7 + (section.start_time.min/60.0)) * 6
    return top_px
  end

  def mini_section_height_px( section )
    return section.duration * 6
  end

end
