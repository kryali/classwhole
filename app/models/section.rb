class Section < ActiveRecord::Base
  belongs_to :course
#  has_and_belongs_to_many :users

  # Configuration Key to access the configurations_hash of a register_course
  # this may need to become more advanced depending on if we discover unusual courses
  def configuration_key
    if self.course_subject_code == "PHYS" #PHYSICS DEPARTMENT Y U NO CONSISTENT?
      key = self.course_subject_code
    elsif self.code == nil
      key = self.course_subject_code
    else
      key = self.code.at(0)
      #append number to key if it exists at 1 (for mathematica sections B8, X8, etc)
      at1 = self.code.at(1)
      key << at1 if (true if Integer(at1) rescue false)
    end
    return key
  end

  # Description: Checks to see if there is a time conflict
  def time_conflict?(days, start_time, end_time)
    return false if self.start_time == nil or start_time == nil
    day_array = days.split("")
    day_array.each do |day|
      if( self.days.include?(day) )
        if (self.start_time.to_i   >= start_time.to_i and self.start_time.to_i <= end_time.to_i) or 
           (  self.end_time.to_i   >= start_time.to_i and   self.end_time.to_i <= end_time.to_i)
          return true
        end
      end
    end
    return false
  end

  def has_time_conflict?(section, time_constraints)
    if time_constraints == nil
      return false
    end
    time_constaints.each do |time_constraint|
      if section.time_conflict?(time_constraint.days, time_constraint.start_time, time_constraint.end_time)
        return true
      end
    end
    return false
  end

  # Description: This function ensures that no two sections are conflicting
  #   Method: Make sure that sectionb's start and end time is not between sectiona's start and end time
  def section_conflict?(section)
    return time_conflict?(section.days, section.start_time, section.end_time)
  end

  def schedule_conflict?(schedule)
    schedule.each do |section|
      return true if self.section_conflict?(section)
    end
    return false
  end

  def course_to_s
    return "#{course_subject_code} #{course_number}"
  end

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

	#NOTE: move tihs somewhere where every method can use it
	def full_name(abbreviation)
	end

end
