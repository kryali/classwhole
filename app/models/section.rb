class Section < ActiveRecord::Base
  belongs_to :course
#  has_and_belongs_to_many :users

  # Description: Checks to see if there is a time conflict
  def time_conflict?(days, start_time, end_time)
    day_array = days.split("")
    day_array.each do |day|
      if( days.include?(day) )
        if (self.start_time.to_i   >= start_time.to_i and self.start_time.to_i <= end_time.to_i) or 
           (  self.end_time.to_i   >= start_time.to_i and   self.end_time.to_i <= end_time.to_i)
          return true
        end
      end
    end
    return false
  end

  # Description: This function ensures that no two sections are conflicting
  #   Method: Make sure that sectionb's start and end time is not between sectiona's start and end time
  def section_conflict?(section)
    return time_conflict?(section.days, section.start_time, section.end_time)
  end

end
