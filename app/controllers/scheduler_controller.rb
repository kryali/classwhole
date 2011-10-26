class SchedulerController < ApplicationController

  def index
  end

  def has_conflicts?(schedule, target_section)
    schedule.each do |section|
      return true if section.section_conflict?(target_section)
    end
    return false
  end

  def has_time_conflict?(section, time_constraints)
    if time_constraints == nil
      return false
    end
    time_constaints.each do |time_constraint|
      if section.time_conflict?(time_constraint.days, time_constraint.start_time, time_constraint.end_time)
        return true
      end
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
        #if not has_time_conflict?(section, nil)
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
            lectures << section
          else
            logger.error "section found that does not have a registered section type : #{section.section_type}"
            lectures << section
        end
      end
      class_sections << lectures if lectures.size > 0
      class_sections << discussions if discussions.size > 0
      class_sections << labs if labs.size > 0
    end
    # sort based on fewest number of sections to lower recursions
    class_sections.sort!{|x,y| x.size <=> y.size} #include priority in here too when we implement that
    # get a list of all valid schedules
    generate_schedule_recurse(valid_schedules, class_sections, [], 0)

    valid_schedules.sort!{|x,y| num_holes(x) <=> num_holes(y)}

=begin
    valid_schedules.each do |schedule|
      schedule.each do |section|
        logger.error section.to_json
      end
      logger.error num_holes(schedule)
    end
=end

    @possible_schedules = valid_schedules[0,5]
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

  # find out how many classwholes our schedule has (lol)
  def num_holes(schedule)
    holes = 0
    schedule.each do |section1|
      schedule.each do |section2|
        next if section1 == section2
        day_array = section1.days.split("")
        day_array.each do |day|
          if( section2.days.include?(day) )
            next if( (section1.start_time.to_i - section2.start_time.to_i).abs < 900000 ) # 15 minutes in ms
          end
          holes+=1
        end
      end
    end
    return holes
  end

  def show
  end

  def new
    generate_schedule
  end

end
