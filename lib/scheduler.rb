class Scheduler
  attr_accessor :valid_schedules

  def initialize(user_courses, is_temp_user)
    @courses = []
    if is_temp_user == 1 #if its temp user
      for id in user_courses
        @courses << Register_Course.new(Course.find(id))      
      end
    else #facebook user
      user_courses.each do |course|
        @courses << Register_Course.new(course)
      end
    end  
  end

  # schedule courses
  def schedule_courses
    @valid_schedules = []
    @schedule = []
    @valid = false
    schedule_recursive(0, 0, 0)
  end

  def schedule_recursive(course_index, configuration_index, sections_index)
    if course_index >= @courses.size #valid schedule!
      @valid_schedules << @schedule.clone
      @valid = true
      return
    end
    course = @courses[course_index]
    if configuration_index == course.configurations_array.size
      return
    end
    @valid = false
    configuration = course.configurations_array[configuration_index]
    if sections_index == configuration.size
      schedule_recursive(course_index+1, 0, 0)
      return
    end
    sections = configuration[sections_index]
    sections.each do |section|
      unless section.schedule_conflict?(@schedule)
        @schedule.push(section)
        schedule_recursive(course_index, configuration_index, sections_index+1)
        @schedule.pop
        if @valid
          break
        end
      end
    end
    if sections_index == 0
      schedule_recursive(course_index, configuration_index+1, 0)
    end
  end
end
