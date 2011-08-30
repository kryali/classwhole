# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

require 'xmlsimple'

def ParseSemester(year, season)

  # Initialize
  Major.delete_all
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

  # Iterate through the subjects found in the hash
  catalog['subject'].each do |subject|

    puts "-------\n#{subject['subjectCode']}\n-------\n"

    # Add the subject/major to the database
    currentMajor = Major.create(
        :phone => subject['phone'],
        :webSiteAddress => subject['webSiteAddress'],
        :address2 => subject['address2'],
        :contact => subject['contact'],
        :contactTitle => subject['contactTitle'],
        :subjectDescription => subject['subjectDescription'],
        :subjectCode => subject['subjectCode'],
        :unitName => subject['unitName']
        )

    # Build a url based off of the current subject code
    subjectURL = base_url + "/schedule/" + subject['subjectCode'] + "/index.xml"

    # Fetch the courses for the subject and decrypt the data from the url
    subjectXML_data = Net::HTTP.get_response(URI.parse(subjectURL)).body
    subjectCourses = XmlSimple.xml_in(subjectXML_data, 'ForceArray' => ['course','section'], 'SuppressEmpty' => nil)['subject']['course']

    # Iterate through the courses offered in the class 
    subjectCourses.each do |course|
      currentCourse = currentMajor.courses.create(
          :courseNumber => course['courseNumber'].to_i,
          :hours => course['hours'],
          :description => course['description'],
          :title => course['title'],
          :subjectCode => course['subjectCode'],
          :subjectId => course['subjectId'].to_i
          )

      puts currentCourse.title

      courseSections = course['section']
      courseSections.each do |section|
        currentSection = currentCourse.sections.create(
            :room => section['roomNumber'].to_i,
            :days => section['days'],
            :referenceNumber => section['referenceNumber'].to_i,
            :notes => section['sectionNotes'],
            :type => section['sectionType'],
            :instructor => section['instructor'],
            :startTime => (Time.parse(section['startTime']) rescue nil), #NOTE Time value can be "ARRANGED", not an actual time, so should we store this?
            :endTime => (Time.parse(section['endTime']) rescue nil),
            :building => section['building'],
            :sectionId => section['sectionId']
            )
      end
    end
  end
end

ParseSemester( '2011', 'spring' )
