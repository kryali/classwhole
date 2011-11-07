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
      key = section.configuration_key
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
        @configurations_array[i][j].sort!{|x,y| x.start_time.to_i <=> y.start_time.to_i}
      end
    end
  end

end
