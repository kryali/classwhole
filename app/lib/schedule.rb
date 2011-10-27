class Schedule
  attr_accessor :sections

  def initialize(sections)
    @sections = sections
  end

  def attempt_add_section?(section)
    @sections.each do |scheduled_section|
      return false if section.section_conflict?(scheduled_section)
    end
    @sections.push(section)
    return true
  end

  def pop
    return @sections.pop
  end

  # find out how many classwholes our schedule has (lol)
  # considering a hole to be if section1 has no classes within 15 minutes before it
  def holes
    num_holes = 0
    @sections.each do |section1|
      @sections.each do |section2|
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
