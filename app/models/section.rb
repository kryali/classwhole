class Section < ActiveRecord::Base
  belongs_to :course
  belongs_to :configuration
  has_many :meetings


  # Configuration Key to access the configurations_hash of a register_course
  # this may need to become more advanced depending on if we discover unusual courses
  def configuration_key
    if self.course_subject_code == "PHYS" #PHYSICS DEPARTMENT Y U NO CONSISTENT?
      key = self.course_subject_code
    elsif self.code.nil? #If there is no code, assume all courses are in the same configuration
      key = self.course_subject_code
    elsif (true if Integer(self.code) rescue false) #If the code is an integer, assume the courses should be in the same configuration
      key = self.course_subject_code
    elsif self.code.length == 1
      key = self.course_subject_code
    elsif self.code.length == 2
      if (true if Integer(self.code[0]) rescue false)
        key = self.code[1]
      else
        key = self.code[0]
      end
    else
      key = self.code[0]
      if (true if Integer(self.code[1]) rescue false)
        unless (true if Integer(self.code[2]) rescue false)
          key << self.code[1]
        end
      else
        key << self.code[0]
      end
    end
    return key
  end

  # Description: Checks to see if there is a conflict between 2 meetings
  def meeting_conflict?(meeting1, meeting2)
    return false if meeting1.start_time.nil? or meeting2.start_time.nil?
    section_days = meeting2.days.split("")
    section_days.each do |day|
      if( meeting1.days.include?(day) )
        if (meeting1.start_time.to_i >= meeting2.start_time.to_i and meeting1.start_time.to_i <= meeting2.end_time.to_i) or 
           (meeting2.start_time.to_i >= meeting1.start_time.to_i and meeting2.start_time.to_i <= meeting1.end_time.to_i)
          return true
        end 
      end
    end
    return false
  end

  # Description: This function ensures that no two sections are conflicting
  #   Method: check that these sections fall within the same semester slot then
  #     check each meeting time to see if any conflict
  def section_conflict?(section)
    if self.part_of_term == "A" and section.part_of_term == "B" or self.part_of_term == "B" and section.part_of_term == "A"
      self.meetings.each do |self_meeting|
        section.meetings.each do |section_meeting|
          return meeting_conflict?(self_meeting, section_meeting)
        end
      end
    end
    return false
  end

  # Is there a conflict between this section and this schedule?
  def schedule_conflict?(schedule)
    schedule.each do |section|
      return true if self.section_conflict?(section)
    end
    return false
  end

  def course_to_s
    return "#{course_subject_code} #{course_number}"
  end




  def self.hour_range(sections)
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

end
