module SchedulerHelper

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
    earliest_start_hour = 24 * 60
    latest_end_time = 0
    sections.each do |section|
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
      days = section.days.split("")
      days.each do |day|
        sections_by_days[day].push(section)
      end
    end

    return  sections_by_days
  end

  def section_top_px( section, start_hour )
    scheduler_block_height = 74
    top_px = (section.start_time.hour - start_hour) * scheduler_block_height
    return top_px
  end

  def section_height_px( section )
    scheduler_block_height = 74
    return section.duration * scheduler_block_height
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

  def shorten(text, length, end_string = ' ...')
    return text if( text.length <= length )
    letters = text.split("")
    return letters[0..(length-1)].join + "..."
  end

end
