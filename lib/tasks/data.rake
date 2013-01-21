require 'xmlsimple'
require 'net/http'
require 'pp'
require 'time'

#xml_data_second8week = Net::HTTP.get_response(URI.parse(url_second8week)).body
#catalog_first8week = XmlSimple.xml_in(xml_data_first8week, 'ForceArray' => ['subject'], 'SuppressEmpty' => nil)

namespace :data do 
  task :update => [:environment] do
    puts "Parsing?"
    UIUCParser.parse_year 2013
    SectionGroupingGenerator.seed_term DefaultSemester::SEASON, DefaultSemester::YEAR
  end

  task :seed, [:season, :year] => [:environment] do |t, args|
    puts "Seeding #{args[:season]} #{args[:year]}" 
    year = args[:year]
    season = args[:season]
    UIUCParser.parse_term_sy season, year
    SectionGroupingGenerator.seed_term season, year
  end
end
