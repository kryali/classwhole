class Scheduler
  attr_accessor :valid_schedules

  def initialize(user_courses)
    @courses = user_courses
  end

  # schedule courses
  def schedule_courses
    @configuration_permutations = []
    @permutation = []
    initialize_configuration_permutations(0)
    @valid_schedules = []
    @schedule = []
    @configuration_permutations.each do |permutation|
      @valid = false
      schedule_permutation_recursive(permutation, 0, 0)
    end
  end

  def initialize_configuration_permutations(course_index)
    if course_index == @courses.size
      @configuration_permutations << @permutation.clone
      return
    end
    course = @courses[course_index]
    course.configurations.each do |configuration|
      @permutation.push(configuration)
      initialize_configuration_permutations(course_index+1)
      @permutation.pop
    end
  end

  def schedule_permutation_recursive(permutation, configuration_index, sections_index)
    if configuration_index == permutation.size #valid schedule!
      @valid_schedules << @schedule.clone
      @valid = true
      return
    end
    configuration = permutation[configuration_index]
    if sections_index == configuration.sections_array.size
      schedule_permutation_recursive(permutation, configuration_index + 1, 0)
      return
    end
    sections = configuration.sections_array[sections_index]
    sections.each do |section|
      unless section.schedule_conflict?(@schedule)
        @schedule.push(section)
        schedule_permutation_recursive(permutation, configuration_index, sections_index+1)
        @schedule.pop
        if @valid
          break
        end
      end
    end    
  end

  # 'Static' shit

  # prepares a section object for json
  def self.build_section( section )
    meetings = []
    section.meetings.each do |meeting|
        meeting["instructors"] = meeting.instructors
        meeting["building"] = meeting.building
        meetings << meeting
    end
    section['short_type'] = section.short_type_s
    section['meetings'] = meetings
    return section
  end
end
