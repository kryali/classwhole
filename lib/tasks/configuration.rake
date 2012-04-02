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

end

namespace :configuration do 

  #MIGRATE TASKS

  # all
  task :migrateall, :season, :year, :needs => [:environment] do |t, args|
    Dir.foreach("db/configuration/#{args[:season]}_#{args[:year]}/") do |filename|
      if filename.end_with?(".json")
        path = "db/configuration/#{args[:season]}_#{args[:year]}/#{filename}"
        CustomConfigurationParser.parse_file path
      end
    end
  end

  #specific file
  task :migrate, :season, :year, :filename, :needs => [:environment] do |t, args|
    filename = "db/configuration/#{args[:season]}_#{args[:year]}/#{args[:filename]}"
    filename = filename + ".json" unless filename.end_with?(".json")
    CustomConfigurationParser.parse_file filename
  end

  # GENERATE TASK

  task :generate, :season, :year, :subject_code, :number, :show_configurations, :needs => [:environment] do |t, args|
    semester = Semester.find_by_season_and_year(args[:season], args[:year])
    subject = semester.subjects.find_by_code(args[:subject_code])
    course = subject.courses.find_by_number(args[:number])
    directory_name = Dir::pwd + "/db/configuration/#{args[:season]}_#{args[:year]}"
    unless FileTest::directory?(directory_name)
      Dir::mkdir(directory_name)
    end
    
    course_data = {}
    course_data[:season] = args[:season]
    course_data[:year] = args[:year]
    course_data[:subject_code] = course.subject_code
    course_data[:number] = course.number

    if args[:show_configurations]
      course_data[:configurations] = {}
      course.configurations.each do |configuration|
        configuration_data = {}
        configuration_data[:sections] = {}
        configuration.sections.each do |section|
          section_data = {}
          section_data[:crn] = section.reference_number
          section_data[:code] = section.code
          configuration_data[:sections][section.short_type] ||= []
          configuration_data[:sections][section.short_type] << section_data
        end
        course_data[:configurations][configuration.key] = configuration_data[:sections]
      end
    else
      course_data[:sections] = {}
      course.sections.each do |section|
        section_data = {}
        section_data[:crn] = section.reference_number
        section_data[:code] = section.code
        course_data[:sections][section.short_type] ||= []
        course_data[:sections][section.short_type] << section_data
      end
    end

    File.open("db/configuration/#{args[:season]}_#{args[:year]}/#{args[:subject_code]}_#{args[:number]}.json", 'w+') do |f|
      f << JSON.pretty_generate(course_data)
    end
  end
end
