class Meeting < ActiveRecord::Base
  belongs_to :building
  belongs_to :section
  has_and_belongs_to_many :instructors


  def duration
    return (end_time.hour - start_time.hour) + (end_time.min - start_time.min)/60.0
  end


  def duration_s
    return "#{print_time(start_time)}-#{print_time(end_time)}"
  end

  # NOTE: move this somewhere where every method can use it
  def print_time(time)
    hour = time.hour
    if( time.hour > 12 and time.hour < 24)
      return "#{time.hour-12}:%02dpm" % time.min
    elsif ( hour < 12 and hour != 0)
      return "#{time.hour}:%02dam" % time.min
    elsif ( hour == 24 )
      return "#{time.hour-12}:%02dam" % time.min
    elsif ( hour == 12 )
      return "#{time.hour}:%02dpm" % time.min
    end
    return "nil"
  end



end



