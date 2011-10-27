class Register_Course
  attr_accessor :section_configurations
  
  def initialize(course)
    @course = course
    generate
  end

  def generate
    @section_configurations = {}
    @course.sections.each do |section|
      key = configuration_key(section)
      @section_configurations[key] ||= {}
      @section_configurations[key][section.section_type] ||= []
      @section_configurations[key][section.section_type] << section
    end
    @section_configurations = @section_configurations.sort_by{|k,config| config.length}
    for i in 0...@section_configurations.length
      @section_configurations[i] = @section_configurations[i][1].sort_by{|k,sections| sections.length}
      for j in 0...@section_configurations[i].length
        @section_configurations[i][j] = @section_configurations[i][j][1]
      end
    end
  end

  # this may need to become more advanced depending on if we discover unusual courses
  def configuration_key(section)
    key = section.code.at(0)
    #append number to key if it exists at 1 (for mathematica sections B8, X8, etc)
    at1 = section.code.at(1)
    key << at1 if true if Integer(at1) rescue false
    return key
  end
end
