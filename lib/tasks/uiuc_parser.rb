require 'xmlsimple'
require 'net/http'
require 'pp'

#xml_data_second8week = Net::HTTP.get_response(URI.parse(url_second8week)).body
#catalog_first8week = XmlSimple.xml_in(xml_data_first8week, 'ForceArray' => ['subject'], 'SuppressEmpty' => nil)

class UIUCParser
  @base_url = "http://courses.illinois.edu/cisapp/explorer/schedule/"

  def self.parse_meeting(meeting, current_section)
    current_meeting = Meeting.new
    current_meeting.start_time = meeting["start"][0] if meeting.key?("start") and meeting.key?("end")    
    current_meeting.end_time = meeting["end"][0] if meeting.key?("end")
    current_meeting.room_number = meeting["roomNumber"][0]    if meeting.key?("roomNumber")      
    current_meeting.days = meeting["daysOfTheWeek"][0].strip if meeting.key?("daysOfTheWeek")
    current_meeting.class_type = meeting["type"][0]["content"]       if meeting.key?("type")
    current_meeting.building = meeting["buildingName"][0] if meeting.key?("buildingName")
    current_meeting.section_id = current_section.id
    current_meeting.short_type = meeting["type"][0]["code"]
    
    #fuk dis shit
    #instructor_list = []
    #if not meeting["instructors"][0].empty?
    #  for instructor in  meeting["instructors"][0]["instructor"]
    #    current_meeting.instructors << instructor["content"]
    #    Instructor.add( instructor["content"], current_section.course )
    #  end
    #end   
    #current_meeting.instructors = instructor_list
    
    current_meeting.save!
  end 

  def self.parse_section(section_xml, current_course, name)
    course_number = section_xml["parents"][0]["course"].first[0] #probably a better way to do this     
    href = section_xml["href"]
    match_crn = /\/(?<crn>[0-9]+)\.xml/.match(href)
    crn =  match_crn[:crn]     
    # this (class)whole if-else business is just so if there is a 
    # fucked up entry where a section has no code (like "AL1"),
    # this won't crash     
    if section_xml.has_key?("sectionNumber")   
      code = section_xml["sectionNumber"][0] 
    else
      code = ""
    end   
    Section.transaction do    
      current_section = current_course.sections.find_by_reference_number(crn)
      if current_section.nil?
        current_section = current_course.sections.new
      end
      current_section.reference_number = crn        
      current_section.code = code
      current_section.part_of_term = 3
      if section_xml.key?("partOfTerm")
        partOfTerm = section_xml["partOfTerm"][0]
        if partOfTerm == "A"
          current_section.part_of_term = 1
        elsif partOfTerm == "B"
          current_section.part_of_term = 2
        end
      end
      current_section.notes = section_xml["sectionNotes"][0] if section_xml.key?("sectionNotes")
      #1 means course is open, 0 means it's not    
      if section_xml["enrollmentStatus"][0].include?("Closed")
        enrollment_status = 0
      elsif section_xml["enrollmentStatus"][0].include?("Restricted")
        enrollment_status = 2
      elsif section_xml["enrollmentStatus"][0].include?("Open")
        enrollment_status = 1
      else
        enrollment_status = 0
      end
      current_section.course_number = course_number  
      current_section.enrollment_status = enrollment_status
      current_section.special_approval = section_xml["specialApproval"][0]     if section_xml.has_key?("specialApproval")
      current_section.section_type = section_xml["meetings"][0]["meeting"].first[1]["type"][0]["content"] #gotta be a better way
      current_section.short_type = section_xml["meetings"][0]["meeting"].first[1]["type"][0]["code"]
      current_section.course_subject_code = section_xml["parents"][0]["subject"].first[0]
      current_section.course_title = section_xml["parents"][0]["course"].first[1]["content"]
      current_section.code = section_xml["sectionNumber"][0].strip    if section_xml.has_key?("sectionNumber")
      if section_xml.has_key?("creditHours")
        current_section.hours = section_xml["creditHours"][0].scan(/\d+/).map{|n| n.to_i}[0]
      else
        current_section.hours = 0
      end
      current_section.start_date = DateTime.parse(section_xml["startDate"][0]) if section_xml.key?("startDate")
      current_section.end_date = DateTime.parse(section_xml["endDate"][0]) if section_xml.key?("endDate")

      current_section.save!
      # iterate through the meetings
      meetings = section_xml["meetings"][0]["meeting"]
      meetings.each do |id, meeting|
        self.parse_meeting(meeting, current_section)
      end
    end  
  end

  def self.parse_course(course_xml, current_subject, name) 
    puts name    
    course_number = name.split(" ")[1].to_i
    Course.transaction do
      current_course = current_subject.courses.find_by_number(course_number)
      if current_course.nil?
        current_course = current_subject.courses.new
      end       
      current_course.number = course_number    
      #current_course.credit_hours = course_xml["creditHours"][0].split(" ")[0].to_i if course_xml.key?("creditHours")
      current_course.description = course_xml["description"][0] if course_xml.key?("description")
      current_course.title = course_xml["label"][0]  if course_xml.key?("label")
      current_course.subject_code = name.split(" ")[0]
      hours = course_xml["creditHours"][0].scan(/\d+/).map{|n| n.to_i}
      if hours.size == 1
        current_course.hours_min = hours[0]
        current_course.hours_max = hours[0]
      elsif hours.size == 2
        current_course.hours_min = hours[0]
        current_course.hours_max = hours[1]
      end
      current_course.save!
      sections = course_xml["detailedSections"][0]["detailedSection"] if course_xml.key?("detailedSections")
      sections.each do |id, detailedSection|
        self.parse_section detailedSection, current_course, id
      end 
    end     
  end

  #current URL -
  def self.parse_subject( subject_code, subject, current_semester ) 
    puts "=====#{subject_code}====="
    url = subject["href"] + "?mode=cascade"
    uri = URI.parse( url )
    xml_str = Net::HTTP.get_response( uri ).body
    begin
      term_xml = XmlSimple.xml_in( xml_str, { 'KeyAttr' => 'id' } )
    rescue ArgumentError
      return
    end
    # Add subjects, like ECE
    Subject.transaction do      
      current_subject = current_semester.subjects.find_by_code(subject_code)  
      if current_subject.nil?
        current_subject = current_semester.subjects.new
        current_subject.code = subject_code        
      end       
      current_subject.contact = term_xml["contactName"][0] if term_xml.key?("contactName")
      current_subject.contact_title = term_xml["contactTitle"][0] if term_xml.key?("contactTitle")
      current_subject.address1 = term_xml["addressLine1"][0] if term_xml.key?("addressLine1")
      current_subject.address2 = term_xml["addressLine2"][0] if term_xml.key?("addressLine2")
      current_subject.title = term_xml["label"][0] if term_xml.key?("label")
      current_subject.phone = term_xml["phoneNumber"][0] if term_xml.key?("phoneNumber")
      current_subject.web_site_address = term_xml["webSiteURL"][0] if term_xml.key?("webSiteURL")  
      current_subject.save!
      courses = term_xml["cascadingCourses"][0]["cascadingCourse"] if term_xml.key?("cascadingCourses")
      #for each course in the subject      
      puts "#{current_subject.title}"
      courses.each do |id, cascadingCourse|
        self.parse_course cascadingCourse, current_subject, id
      end
    end
  end

  def self.parse_term_sy(season, year)
    base_term_url = "http://courses.illinois.edu/cisapp/explorer/schedule/"
    term_url = base_term_url + "#{year}/#{season}.xml"
    title = "#{season} #{year}"
    self.fetch_term_data( season, year, title, term_url)
  end

  def self.fetch_term_data(season, year, title, term_url)
    uri = URI.parse( term_url )
    xml_str = Net::HTTP.get_response( uri ).body
    begin 
      term_xml = XmlSimple.xml_in( xml_str, { 'KeyAttr' => 'id' } )
    rescue ArgumentError
      puts "Bad term"
      puts "attempted #{term_url}"
      puts "shitty cites api returned"
      pp xml_str
      return
    end
    # find the current semester by year and seasn (later add school_id)
    # if the entry doesn't exist, create it    
    current_semester = Semester.find_by_year_and_season(year, season)  
    if current_semester.nil?
      current_semester = Semester.new
      current_semester.year = year
      current_semester.season = season
      current_semester.save!
    end    
    subjects = term_xml["subjects"][0]["subject"]
    subjects.each do |id, subject|
        self.parse_subject id, subject, current_semester
    end
  end

  def self.parse_term( term )
    title = term["content"]
    puts "=====Parsing #{title}====="
    term_url = term["href"]
    season = title.split(" ")[0]
    year = title.split(" ")[1]
    self.fetch_term_data( season, year, title, term_url )
  end

  # Takes a term, and parses the data into the table
  def self.parse_terms( terms )
    terms.each do |id, term|
      self.parse_term( term )
    end
  end

  # Gets the list of the current terms for the "year" parameter (fall, summer, spring)
  def self.parse_year( year )
    xml_year_url = @base_url + year.to_s + ".xml"
    uri = URI.parse(xml_year_url)
    xml_year_data = Net::HTTP.get_response( uri ).body
    catalog_year = XmlSimple.xml_in( xml_year_data, { 'KeyAttr' => 'id' } )
    terms = catalog_year["terms"][0]["term"]
    self.parse_terms( terms )
  end

  def add(hash, key, current)
    if hash.key?(key)    
      current.attribute = hash[key]
    end
  end
end