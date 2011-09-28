class Section < ActiveRecord::Base
  belongs_to :course
#  has_and_belongs_to_many :users

  # Description: This function ensures that no two sections are conflicting
  #   Method: Make sure that sectionb's start and end time is not between sectiona's start and end time
  def conflict?(section)

    # Check for day conflicts
    day_array = days.split("")
    day_array.each do |day|

      # If we have a day conflict, check for an hour and minutes conflict
      if( section.days.include?(day) )
        if (start_time.to_i   >= section.start_time.to_i and start_time.to_i <= section.end_time.to_i) or
           (  end_time.to_i   >= section.start_time.to_i and   end_time.to_i <= section.end_time.to_i)
          return true
        end
      end
    end

    return false
  end
end
