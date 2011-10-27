class Register_Course
  attr_accessor :configurations_hash, :configurations_array
  
  def initialize(course)
    @course = course
    generate_hash
    generate_array
  end

  #creates a hash of all the sections for this course
  def generate_hash
    @configurations_hash ||= {}
    @course.sections.each do |section|
      key = configuration_key(section)
      @configurations_hash[key] ||= {}
      @configurations_hash[key][section.section_type] ||= []
      @configurations_hash[key][section.section_type] << section
    end
  end

  #creates an array of all the sections for this course
  #sorts based on array sizes
  def generate_array
    @configurations_array = @configurations_hash.sort_by{|k,config| config.length}
    for i in 0...@configurations_array.length
      @configurations_array[i] = @configurations_array[i][1].sort_by{|k,sections| sections.length}
      for j in 0...@configurations_array[i].length
        @configurations_array[i][j] = @configurations_array[i][j][1]
      end
    end
  end

  # this may need to become more advanced depending on if we discover unusual courses
  def configuration_key(section)
    key = section.code.at(0)
    #append number to key if it exists at 1 (for mathematica sections B8, X8, etc)
    at1 = section.code.at(1)
    key << at1 if (true if Integer(at1) rescue false)
    return key
  end
end
