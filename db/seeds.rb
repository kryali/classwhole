# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# TODO: Add more functions to make the clone more readable

require 'xmlsimple'


# TODO: FIX THIS FOR SPRING SEMESTER!!  
@semester_start_date = Time.parse("22-Aug-11")
@semester_end_date   = Time.parse("07-Dec-11")

#
# Description: takes a  string in the format "01:40 PM" and parses it 
#              for a a Time object
# Time.utc(year, month, day, hour, min) → time
#
def parse_hours( start_time_string, end_time_string)
  start_time_match = /(?<hour>\d\d):(?<min>\d\d)\s*(?<am_pm>\w+)/.match(start_time_string)
  return nil if not start_time_match

  end_time_match = /(?<hour>\d\d):(?<min>\d\d)\s*(?<am_pm>\w+)/.match(end_time_string)
  return nil if not end_time_match

  # this year month and day do not matter, as long as it is consistent    
  # TODO: Don't hardcode year you moron
  start_time = Time.utc(1990, 7, 1, start_time_match[:hour].to_i, start_time_match[:min].to_i)
    end_time = Time.utc(1990, 7, 1, end_time_match[:hour].to_i,   end_time_match[:min].to_i)
  return start_time, end_time
end

def ParseSemester(year, season)

  # Initialize
  Semester.delete_all
  Subject.delete_all
  Course.delete_all
  Section.delete_all

  # for the loops (they are mostly hash iterators) ,  k stands for key and v stand for value

  # Build the URLs
  # ex: semester = "2011/spring"
  semester = year + "/" + season
  base_url = "http://courses.illinois.edu/cis/" + semester 
  url = base_url + "/schedule/index.xml"

  # Grab the response from the URL as a string
  xml_data = Net::HTTP.get_response(URI.parse(url)).body

  # Turn the string into a hash of data 
  catalog = XmlSimple.xml_in(xml_data, 'ForceArray' => ['subject'], 'SuppressEmpty' => nil)

  currentSemester = Semester.create(:year => year, :season => season)

  Subject.transaction do
  # Iterate through the subjects found in the hash
  catalog['subject'].each do |subject|

    puts "-------\n#{subject['subjectCode']}\n-------\n"

    # Add the subject/major to the database
    currentMajor = currentSemester.subjects.create(
        :phone => subject['phone'],
        :web_site_address => subject['webSiteAddress'],
        :address2 => subject['address2'],
        :contact => subject['contact'],
        :contact_title => subject['contactTitle'],
        :title => subject['subjectDescription'],
        :code => subject['subjectCode'],
        :unit_name => subject['unitName']
    )

    # Build a url based off of the current subject code
    subjectURL = base_url + "/schedule/" + subject['subjectCode'] + "/index.xml"

    # Fetch the courses for the subject and decrypt the data from the url
    subjectXML_data = Net::HTTP.get_response(URI.parse(subjectURL)).body
    subjectCourses = XmlSimple.xml_in(subjectXML_data, 'ForceArray' => ['course','section'], 'SuppressEmpty' => nil)['subject']['course']

    Course.transaction do
      # Iterate through the courses offered in the class 
      subjectCourses.each do |course|

        currentCourse = currentMajor.courses.create(
            :number => course['courseNumber'].to_i,
            :hours => course['hours'].to_i,
            :description => course['description'],
            :title => course['title'],
            :subject_code => course['subjectCode'],
            :subject_id => course['subjectId'].to_i
            )
        puts currentCourse.title

        courseSections = course['section']
        Section.transaction do
          courseSections.each do |section|

            # If there is a date rage specified, use it, otherwise default to semester
            # omg this totally worked
            quarter_duration = section['sectionDateRange']
            if not quarter_duration
              start_date = @semester_start_date
                end_date = @semester_end_date
            else
              dates = quarter_duration.split(" - ")
              start_date = Time.parse(dates[0])
              end_date = Time.parse(dates[1])
            end

            section_start_time, section_end_time = parse_hours(section['startTime'], section['endTime'])

            currentSection = currentCourse.sections.create(
              :room => section['roomNumber'].to_i,
              :days => section['days'],
              :reference_number => section['referenceNumber'].to_i,
              :notes => section['sectionNotes'],
              :section_type => section['sectionType'],
              :instructor => section['instructor'],

              # Time value can be "ARRANGED", not an actual time, so this is stored as nil
              :start_time => section_start_time,
              :end_time => section_end_time,
              :start_date => start_date,
              :end_date => end_date,
              :building => section['building'],
              :code => section['sectionId']
              )
          end
        end
      end
    end
  end
  end
end

ParseSemester( '2011', 'fall' )
