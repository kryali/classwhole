class SchedulerController < ApplicationController

  def index
  end

  def has_conflicts?(schedule, target_section)
    return false
    schedule.each do |section|
      return true if section.conflict?(target_section)
    end
    return false
  end

  def generate_schedule
    valid_schedules = []
    class_sections = []
    current_user.courses.each do |course|
      lectures = []
      discussions = []
      labs = []

      course.sections.each do |section|
        #remove incompatible sections (single constraints)
        #if incompatible
        #  next
        #end
        case section.section_type
          when "LEC"
            lectures << section
          when "LCD"
            lectures << section
          when "DIS"
            discussions << section
          when "LBD"
            discussions << section
          when "LAB"
            labs << section
          when nil
            logger.error "HOLY SHIT WTF WHY IS THIS NULL? pray this is a lecture"
            lectures << section
          else
            logger.error "section found that does not have a registered section type : #{section.section_type}"
        end
      end
      class_sections << lectures if lectures.size > 0
      class_sections << discussions if discussions.size > 0
      class_sections << labs if labs.size > 0
    end

    class_sections.sort!{|x,y| x.size <=> y.size} #include priority in here too when we implement that
    generate_schedule_recurse(valid_schedules, class_sections, [], 0)

    @possible_schedules = valid_schedules[0,5].to_json
    render 'show'
  end
    

  def generate_schedule_recurse(valid_schedules, class_sections, schedule, current_section)
    if current_section >= class_sections.size
      return true
    end
    section_list = class_sections[current_section]
    section_list.each do |section|
      unless has_conflicts?(schedule, section)
        schedule.push(section)
        fit = generate_schedule_recurse(valid_schedules, class_sections, schedule, current_section+1)
        if fit
          valid_schedules << schedule.clone
        end
        schedule.pop
      end
    end
    return false
  end

  def show
  end

  def new
    generate_schedule
  end

end
