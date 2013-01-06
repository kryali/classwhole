class Section < ActiveRecord::Base
  belongs_to :course
  belongs_to :configuration
  has_many :meetings

  def short_type_s
    return short_type || "N/A"
  end

  # Configuration Key generation
  # this may need to become more advanced depending on if we discover unusual courses
  def generate_configuration_key
    if self.course_subject_code == "PHYS" #PHYSICS DEPARTMENT Y U NO CONSISTENT?
      key = "ALL"
    elsif self.code.nil? #If there is no code, assume all courses are in the same configuration
      key = "NON"
    elsif self.short_type == "ONL" or self.short_type == "ARR"
      key = "ARR"
    elsif (true if Integer(self.code) rescue false) #If the code is an integer, assume the courses should be in the same configuration
      key = "INT"
    elsif self.code.length == 1 # code is letters of length 1
      key = "ALL"
    elsif self.code.length == 2
      key = self.code
    else
      key = self.code[0]
      if (true if Integer(self.code[1]) rescue false)
        unless (true if Integer(self.code[2]) rescue false)
          key << self.code[1]
        end
      end
    end
    return key
  end

  # Description: This function ensures that no two sections are conflicting
  #   Method: check that these sections fall within the same semester slot then
  #     check each meeting time to see if any conflict
  def section_conflict?(section)
    if self.part_of_term & section.part_of_term > 0
      self.meetings.each do |self_meeting|
        section.meetings.each do |section_meeting|
          return true if self_meeting.meeting_conflict?(section_meeting)
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
      section.meetings.each do |meeting|
        next if meeting.start_time.nil?
        current_start_time = meeting.start_time.hour * 60 + meeting.start_time.min
        current_end_time = meeting.end_time.hour * 60 + meeting.end_time.min
        earliest_start_hour = current_start_time if current_start_time < earliest_start_hour
        latest_end_time = current_end_time if current_end_time > latest_end_time
      end
    end

    earliest_start_hour = (earliest_start_hour.to_f/60).ceil
    latest_end_hour = (latest_end_time.to_f/60).ceil
    return earliest_start_hour, latest_end_hour
  end

  def reason
    if enrollment_status == 0
      "Full/Closed"
    elsif enrollment_status == 1
      "Open"
    else
      notes || special_approval || "Open (Restricted)"
    end
  end
end
