require 'xmlsimple'
require 'json'

# ONLY JON SHOULD USE THIS
# CUZ THIS SHIT IS WEIRD LOL
# rake configuration:generate[fall,2012,CS,125,true]
# rake configuration:migrate[fall,2012,CS_125]

class CustomConfigurationParser

  def self.parse_file( filename )
    puts "Migrating #{filename}"
    f = File.read(filename)
    course_data = JSON.parse(f)
    semester = Semester.find_by_season_and_year(course_data["season"], course_data["year"])
    subject = semester.subjects.find_by_code(course_data["subject_code"])
    course = subject.courses.find_by_number(course_data["number"])
    course_data["configurations"].each do |configuration_key, section_types|
      c = course.configurations.new(:key=>configuration_key)
      section_types.each do |section_type, sections|
        sections.each do |section_data|
          section = course.sections.find_by_reference_number(section_data["crn"])
          section.configuration = c
          section.save
        end
      end
      c.save
    end
    course.configurations.each do |configuration|
      Configuration.delete(configuration.id) if configuration.sections.count == 0
    end
  end

  def self.seed_course (course)
    puts "Seeding #{course.subject_code} #{course.number}"
    # generate new configurations
    course.sections.each do |section|
      key = section.generate_configuration_key
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

end

namespace :configuration do 

  #SEED

  task :seed, [:season, :year] => [:environment] do |t, args|
    #re seed all courses
    semester = Semester.find_by_season_and_year(args[:season], args[:year])
    semester.subjects.all.each do |subject|
      subject.courses.all.each do |course|
        CustomConfigurationParser.seed_course course
      end
    end
  end
end
