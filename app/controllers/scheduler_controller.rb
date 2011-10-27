class SchedulerController < ApplicationController

  def index
  end

  def has_conflicts?(schedule, target_section)
    schedule.each do |section|
      return true if section.section_conflict?(target_section)
    end
    return false
  end

  def generate_schedules
    courses = []
    current_user.courses.each do |course|
      courses << Register_Course.new(course)
    end

    # get a list of all valid schedules
    valid_schedules = []
    generate_schedule_recurse(courses, valid_schedules, [], 0)

    #valid_schedules.sort!{|x,y| num_holes(x) <=> num_holes(y)}

=begin
    valid_schedules.each do |schedule|
      schedule.each do |section|
        logger.error section.to_json
      end
      logger.error num_holes(schedule)
    end
=end
    #logger.error valid_schedules[0].to_json
    @possible_schedules = valid_schedules
    render 'show'
  end
    
  def generate_schedule_recurse(courses, valid_schedules, schedule, course_index)
    if course_index >= courses.size #valid schedule!
      valid_schedules << schedule.clone
      return
    end
    course = courses[course_index]
    course.section_configurations.each do |configuration|
      schedule_configuration(configuration, 0, courses, valid_schedules, schedule, course_index)
    end
  end

  def schedule_configuration(configuration, sections_index, courses, valid_schedules, schedule, course_index)
    if sections_index >= configuration.size
      generate_schedule_recurse(courses, valid_schedules, schedule, course_index+1)
      return
    end
    sections = configuration[sections_index]
    sections.each do |section|
      unless has_conflicts?(schedule, section)
        schedule.push(section)
        schedule_configuration(configuration, sections_index+1, courses, valid_schedules, schedule, course_index)
        schedule.pop
      end
    end
  end

  def show
  end

  def new
    generate_schedules
  end

end
