class Meeting < ActiveRecord::Base
  belongs_to :section
  has_and_belongs_to_many :instructors

  def duration
    return (end_time.hour - start_time.hour) + (end_time.min - start_time.min)/60.0
  end

  def duration_s
    return "Online/Arr" if start_time.nil?
    return "#{print_time(start_time)}-#{print_time(end_time)}"
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

    # Description: Checks to see if there is a conflict between 2 meetings
  def meeting_conflict?(other)
    return false if self.start_time.nil? or other.start_time.nil?
    section_days = other.days.split("")
    section_days.each do |day|
      if( self.days.include?(day) )
        if (self.start_time.to_i >= other.start_time.to_i and self.start_time.to_i <= other.end_time.to_i) or 
           (other.start_time.to_i >= self.start_time.to_i and other.start_time.to_i <= self.end_time.to_i)
          return true
        end 
      end
    end
    return false
  end

end

