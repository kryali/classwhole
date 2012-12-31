require 'ostruct'
class Meeting < OpenStruct
  def section
    return Section.find(self.section_id)
  end

  def duration
    return (end_time.hour - start_time.hour) + (end_time.min - start_time.min)/60.0
  end

  def duration_s
    start_time.nil? ? "Online/Arr" : "#{print_time(start_time)}-#{print_time(end_time)}"
  end

  # NOTE: move this somewhere where every method can use it
  def print_time(time)
    hour = time.hour
    time_s = ""
    if( time.hour > 12 and time.hour < 24)
      time_s = "#{time.hour-12}:%02dpm" % time.min
    elsif ( hour < 12 and hour != 0)
      time_s = "#{time.hour}:%02dam" % time.min
    elsif ( hour == 24 )
      time_s = "#{time.hour-12}:%02dam" % time.min
    elsif ( hour == 12 )
      time_s = "#{time.hour}:%02dpm" % time.min
    else
      time_s = "nil"
    end

    return time_s.gsub(/:00/, "")
  end
end
