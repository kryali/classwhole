class Scheduler
  attr_accessor :valid_schedules

  def initialize(user_courses)
    @HOURS = 24
    @GRANULARITY = 10 #minutes
    @BLOCKS_PER_HOUR = 60/@GRANULARITY
    @courses = []
    user_courses.each do |course|
      @courses << Register_Course.new(course)
    end
    @courses.sort!{|x,y| x.configurations_array.size <=> y.configurations_array.size}
  end

  # schedule courses
  def schedule_courses
    @valid = false
    @valid_schedules = []
    @schedule = []
    @schedule_times = [[],[],[],[],[]]

    for i in (0...@HOURS)
      for j in (0...@BLOCKS_PER_HOUR)
        @schedule_times[0] << 0
        @schedule_times[1] << 0
        @schedule_times[2] << 0
        @schedule_times[3] << 0
        @schedule_times[4] << 0
      end
    end

    schedule_recursive(0, 0, 0)
  end

  def schedule_conflict?(section)
    days = day_indices(section.days)
    times = time_range(section.start_time, section.end_time)
    days.each do |day|
      for time in times
        return true if @schedule_times[day][time] > 0
      end
    end
    return false
  end

  def schedule_push(section)
    @schedule << section
    schedule_set_time(section, 3)
  end

  def schedule_pop(section)
    @schedule.pop
    schedule_set_time(section, 0)
  end

  def schedule_set_time(section, value)
    days = day_indices(section.days)
    times = time_range(section.start_time, section.end_time)
    days.each do |day|
      for time in times
        @schedule_times[day][time] = value
      end
    end
  end

  def time_range(start_time, end_time)
    return time_index(start_time) ... time_index(end_time)
  end

  def time_index(time)
    return (time.min / @GRANULARITY) + time.hour * @BLOCKS_PER_HOUR
  end

  def day_indices(days)
    day_indices = []
    for i in 0...days.size
      day_indices << day_index(days[i])
    end
    return day_indices
  end

  def day_index(day)
    case day
    when "M"
      return 0
    when "T"
      return 1
    when "W"
      return 2
    when "R"
      return 3
    when "F"
      return 4
    end
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
      unless schedule_conflict?(section)
        schedule_push(section)
        schedule_recursive(course_index, configuration_index, sections_index+1)
        schedule_pop(section)
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
