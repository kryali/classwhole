require 'xmlsimple'
require 'json'

# regenerate section groupings
# EX: rake groups:generate[fall,2013]

class SectionGroupingGenerator

  def self.seed_course (course)
    puts "Seeding #{course.subject_code} #{course.number}"
    # generate new configurations
    course.sections.each do |section|
      key = self.generate_group_key(section)
      configuration = Configuration.find_by_course_id_and_key(course.id, key)
      if configuration.nil?
        configuration = Configuration.new(:key=>key)
        configuration.course = course
        configuration.save
      end        
      section.configuration = configuration
      section.save
    end
    # remove old configurations
    course.configurations.each do |configuration|
      Configuration.delete(configuration.id) if configuration.sections.count == 0
    end
  end
  
  # Section Group Key generation
  # this may need to become more advanced depending on if we discover unusual courses
  # We'll also have to customize these heavily for different schools
  def self.generate_group_key(section)
    if section.course_subject_code == "PHYS" #PHYSICS DEPARTMENT Y U NO CONSISTENT?
      key = "ALL"
    elsif section.code.nil? #If there is no code, assume all courses are in the same group
      key = "NON"
    elsif section.short_type == "ONL" or section.short_type == "ARR"
      key = "ARR"
    elsif (true if Integer(section.code) rescue false) #If the code is an integer, assume the courses should be in the same group
      key = "INT"
    elsif section.code.length == 1 # code is letters of length 1
      key = "ALL"
    elsif section.code.length == 2
      key = section.code
    else
      key = section.code[0]
      if (true if Integer(section.code[1]) rescue false)
        unless (true if Integer(section.code[2]) rescue false)
          key << section.code[1]
        end
      end
    end
    return key
  end
  
end

namespace :groups do

  #SEED

  task :generate, [:season, :year] => [:environment] do |t, args|
    #re seed all courses
    semester = Semester.find_by_season_and_year(args[:season], args[:year])
    semester.subjects.all.each do |subject|
      subject.courses.all.each do |course|
        SectionGroupingGenerator.seed_course course
      end
    end
  end
end
