class Register_Course
  attr_accessor :configurations_hash, :configurations_array
  
  def initialize(course)
    @course = course
    generate_hash
    generate_array
  end

  #creates a hash of all the sections for this course
  def generate_hash
    sections = {}
    @course.sections.each do |section|
      code = section.code
      sections[code] ||= []
      sections[code] << section
    end
    @configurations_hash ||= {}
    sections.each do |code, section|
      sec = section[0]
      if section.length == 1
        key = sec.configuration_key
        @configurations_hash[key] ||= {}
        @configurations_hash[key][sec.section_type] ||= []
        @configurations_hash[key][sec.section_type] << sec
      else
        if code.length == 1
          key = sec.code
        else 
          key = sec.configuration_key
        end
        @configurations_hash[key] ||= {}
        for i in (0...section.length)
          @configurations_hash[key][i] = [section[i]]
        end
      end
    end
  end

  #creates an array of all the sections for this course
  #sorts based on array sizes
  def generate_array
    @configurations_array = @configurations_hash.sort_by{|k,config| k}
    for i in 0...@configurations_array.length
      @configurations_array[i] = @configurations_array[i][1].sort_by{|k,sections| sections.length}
      for j in 0...@configurations_array[i].length
        @configurations_array[i][j] = @configurations_array[i][j][1]
        @configurations_array[i][j].sort!{|x,y| x.start_time.to_i <=> y.start_time.to_i}
      end
    end
  end

end
