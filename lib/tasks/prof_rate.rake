require 'net/http'
require 'uri'
require 'nokogiri'


def parse_prof_for_letter( letter )
  base_url = 'http://www.ratemyprofessors.com/'
  teacher_url = base_url + 'SelectTeacher.jsp?the_dept=All&sid=1112&orderby=TLName&letter='
  url = teacher_url + letter
  uri = URI.parse( url )
  html = Net::HTTP.get_response( uri ).body
  doc = Nokogiri::HTML::Document::parse( html )

  doc.css('.entry').each do |entry|
    puts "#######"
    name_link = entry.css('.profName a')
    prof_url = name_link.attribute("href")
    prof_name = name_link.children

    easy = entry.css('.profEasy').inner_html
    avg = entry.css('.profAvg').inner_html
    num_ratings = entry.css('.profRatings').inner_html
    puts "#{prof_name} - #{prof_url}"
    puts "RATINGS: \n\teasy-#{easy}\n\tavg-#{avg}\n\tnum-#{num_ratings}"
    puts "#######"
  end
end

def parse_all_profs
  # ('A'..'Z').each do |letter|
  # end
  parse_prof_for_letter 'A'
end

namespace :prof do 
  task :update => [:environment] do
    parse_all_profs
  end
end
