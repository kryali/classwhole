require 'xmlsimple'
require 'net/http'
require 'pp'

#xml_data_second8week = Net::HTTP.get_response(URI.parse(url_second8week)).body
#catalog_first8week = XmlSimple.xml_in(xml_data_first8week, 'ForceArray' => ['subject'], 'SuppressEmpty' => nil)

class UIUCParser
  @base_url = "http://courses.illinois.edu/cisapp/explorer/schedule/"

  def self.parse_subject( subject_code, subject )
    puts "=====#{subject_code}====="
    url = subject["href"] + "?mode=cascade"
    uri = URI.parse( url )
    xml_str = Net::HTTP.get_response( uri ).body
    begin
      term_xml = XmlSimple.xml_in( xml_str, { 'KeyAttr' => 'id' } )
    rescue ArgumentError
      return
    end
    pp term_xml
  end

  def self.parse_term( term )
    title = term["content"]
    puts "=====Parsing #{title}====="
    term_url = term["href"]

      uri = URI.parse( term_url )
      xml_str = Net::HTTP.get_response( uri ).body
    begin 
      term_xml = XmlSimple.xml_in( xml_str, { 'KeyAttr' => 'id' } )
    rescue ArgumentError
      puts "Bad term"
      return
    end

    subjects = term_xml["subjects"][0]["subject"]
    subjects.each do |id, subject|
      self.parse_subject id, subject
    end
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
end


UIUCParser.parse_year 2012

namespace :data do 
  task :update => [:environment] do
    puts "Parsing?"
  end
end
