class Scheduler
  def self.initial_schedule( courses )
    # create a list of configurations for each course
    course_configurations = []
    (0...courses.count).each do |index|
      course_configurations[index] = []
      courses[index].configurations.each do |configuration|
        course_configurations[index] << configuration
      end
    end
    #puts course_configurations.inspect
    course_configurations.sort!{|x,y| x.count <=> y.count}
    @schedule = []
    return self.configuration_recurse([], course_configurations, 0)
  end

  def self.configuration_recurse( configurations, course_configurations, index )
    return self.schedule_configurations(configurations) if index == course_configurations.count
    course_configurations[index].each do |configuration|
      configurations.push(configuration)
      schedule = self.configuration_recurse(configurations, course_configurations, index+1)
      return schedule if @valid
      configurations.pop
    end
    if index == 0 # no valid schedule found
      return []
    end
  end

  def self.schedule_change( schedule, config_new )
    @schedule = schedule
    self.remove_configuration(config_new)
    schedule_configs = [config_new]
    self.schedule_configurations( schedule_configs )
    # couldnt schedule this config? loop until we get a valid schedule
    while not @valid and @schedule.length > 0
      removed_conf = @schedule.first.configuration
      schedule_configs << removed_conf
      self.remove_configuration( removed_conf )
      self.schedule_configurations( schedule_configs )
    end
    return @schedule
  end

  def self.remove_configuration(configuration)
    @schedule.delete_if {|s| s.course == configuration.course}
  end

  def self.schedule_configurations( configurations )
    @schedule = [] if @schedule.nil?
    @valid = false
    self.schedule_configurations_recursive( configurations, 0, 0 )
    return @schedule
  end

  def self.schedule_configurations_recursive(configurations, configuration_index, sections_index)
    if configuration_index == configurations.size #valid schedule!
      @valid = true
      return
    end
    configuration = configurations[configuration_index]
    if sections_index == configuration.sections_array.size
      return self.schedule_configurations_recursive(configurations, configuration_index + 1, 0)
    end
    sections = configuration.sections_array[sections_index]
    sections.each do |section|
      unless section.schedule_conflict?(@schedule)
        @schedule.push(section)
        self.schedule_configurations_recursive(configurations, configuration_index, sections_index+1)
        break if @valid
        @schedule.pop
      end
    end    
  end

  def self.pack_schedule( schedule )
    schedule.each {|section| Scheduler.build_section(section)}
  end

  # prepares a section object for json
  def self.build_section( section )
    meetings = []
    section.meetings.each do |meeting|
        #meeting["instructors"] = meeting.instructors
        #meeting["building"] = meeting.building
        meetings << meeting
    end
    section['short_type'] = section.short_type_s
    section['meetings'] = meetings
    section['reason'] = section.reason
    return section
  end

  def self.parse_hours( start_time_string, end_time_string)
    
    start_time_match = /(?<hour>\d\d):(?<min>\d\d)\s*(?<am_pm>\w+)/.match(start_time_string)
    return nil if not start_time_match

    end_time_match = /(?<hour>\d\d):(?<min>\d\d)\s*(?<am_pm>\w+)/.match(end_time_string)
    return nil if not end_time_match

    start_hour = start_time_match[:hour].to_i
    end_hour = end_time_match[:hour].to_i

    if( start_time_match[:am_pm] == "PM" and start_time_match[:hour].to_i != 12)
      start_hour += 12 
    end
    if( end_time_match[:am_pm] == "PM" and end_time_match[:hour].to_i != 12)
      end_hour += 12 
    end

    # this year month and day do not matter, as long as it is consistent    
    # TODO: Don't hardcode year you moron
    start_time = Time.utc(1990, 7, 1, start_hour, start_time_match[:min].to_i)
      end_time = Time.utc(1990, 7, 1, end_hour,   end_time_match[:min].to_i)
    return start_time, end_time
  end

  def self.get_configurations( courses ) 
    configurations = {}
    course_ids = []
    courses.each do |course|
      course_ids << course.id
      configurations[course.id] = []
      course.configurations.each { |configuration| configurations[course.id] << configuration.key }
    end
    return configurations
  end

  def self.pkg(courses, schedule)
    pkg = []
    courses.each do |course|
      pkg << {
        :name => course.to_s,
        :title => course.title,
        :hours => course.hours,
        :sections => []
      }
    end

    schedule.each do |section|
      section_pkg = {
        :type => section.short_type_s,
        :code => section.code,
        :crn => section.reference_number,
        :meetings => []
      }
      section.meetings.each do |meeting| 
        section_pkg[:meetings] << { 
          :duration => meeting.duration_s,
          :start_time => meeting.start_time,
          :end_time => meeting.start_time,
          :instructor => meeting.instructors[0]
        }
      end
      pkg.select{|course| course[:name] == section.course_to_s}[0][:sections] << section_pkg
    end
    
    return pkg
  end
end
