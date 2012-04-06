class Scheduler

  def self.initial_schedule( courses )
    configurations = []
    courses.each do |course|
      configurations << course.configurations.first
    end
    @schedule = []
    return self.schedule_configurations(configurations)
  end

  def self.schedule_change( schedule, config_new )
    schedule.delete_if {|s| s.course == config_new.course}
    @schedule = schedule
    return self.schedule_configurations( [config_new] )
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
end
