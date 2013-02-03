class Meeting < ActiveRecord::Base
  belongs_to :section
  has_and_belongs_to_many :instructors
  before_destroy {|meeting| meeting.instructors.clear}

  def duration
    return (end_time.hour - start_time.hour) + (end_time.min - start_time.min)/60.0
  end

  def duration_s
    return "Online/Arr" if start_time.nil?
    return "#{print_time(start_time, false)}-#{print_time(end_time, true)}"
  end

  def print_time(time, show_pm)
    show_pm_s = show_pm ? "%P" : ""
    show_min_s = time.min == 0 ? "" : ":%M"
    time.strftime "%-I#{show_min_s}#{show_pm_s}"
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
