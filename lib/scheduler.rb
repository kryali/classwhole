class Scheduler
  attr_accessor :valid_schedules

  def initialize(user_courses)
    @courses = []
    user_courses.each do |course|
      @courses << Register_Course.new(course)
    end
  end

  # schedule configurations
  def schedule_configurations
    @valid_schedules = []
    @schedule = []
    schedule_course_configurations_recursive(0)
  end

  def schedule_course_configurations_recursive(course_index)
    if course_index >= @courses.size #valid schedule!
      @valid_schedules << @schedule.clone
      return
    end
    course = @courses[course_index]
    course.configurations_array.each do |configuration|
      configuration.each do |sections|
        @schedule.push(sections[0])
      end
      schedule_course_configurations_recursive(course_index+1)
      for i in (0...configuration.length)
        @schedule.pop
      end
    end
  end

  # schedule courses
  def schedule_courses
    @valid_schedules = []
    @schedule = []
    schedule_course_recursive(0)
  end

  def schedule_course_recursive(course_index)
    if course_index >= @courses.size #valid schedule!
      @valid_schedules << @schedule.clone
      return
    end
    course = @courses[course_index]
    course.configurations_array.each do |configuration|
      schedule_configuration_sections_recursive(configuration, 0, course_index)
    end
  end

  def schedule_configuration_sections_recursive(configuration, sections_index, course_index)
    if sections_index >= configuration.size
      schedule_course_recursive(course_index+1)
      return
    end
    sections = configuration[sections_index]
    sections.each do |section|
      unless section.schedule_conflict?(@schedule)
        @schedule.push(section)
        schedule_configuration_sections_recursive(configuration, sections_index+1, course_index)
        @schedule.pop
      end
    end
  end

  # find out how many classwholes our schedule has (lol)
  # considering a hole to be if section1 has no classes within 15 minutes before it
  def holes(schedule)
    num_holes = 0
    schedule.each do |section1|
      schedule.each do |section2|
        next if section1 == section2
        day_array = section1.days.split("")
        day_array.each do |day|
          if( section2.days.include?(day) )
            next if( (section1.start_time.to_i - section2.start_time.to_i).abs < 900000 ) # 15 minutes in ms
          end
          num_holes+=1
        end
      end
    end
    return num_holes
  end
end
