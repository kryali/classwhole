#]!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'time'
require 'pp'

FALL_URL = 'http://www.fms.uiuc.edu/FinalExams/index.asp?report=Non%20Combined%20Guidelines/Fall%202011%20Non-Combined%20Guidelines.xml'

def init
  finals_data = scrape_finals_data
  finals_data.each do |day_row|
    day = day_row[0]
    times= day_row[1]
    puts day.inspect
    puts "-----------"
    times.each do |class_time, final_time |
      unless final_time.nil?
        start_time = final_time[:start_time]
        end_time = final_time[:start_time]
        #puts "Class Time: #{class_time}\tStart Time: #{start_time}\tEnd Time:#{end_time}"
        start_time_key = "finals:uiuc:#{class_time.hour}#{class_time.min}:start_time"
        end_time_key = "finals:uiuc:#{class_time.hour}#{class_time.min}:end_time"
        puts start_time_key
        puts end_time_key
        puts "=========="
      end
    end
  end
  #PP.pp finals_data
end

def scrape_finals_data
  doc = Nokogiri::HTML( open(FALL_URL) )
  rows = doc.css("tr.tr1, tr.tr2")
  finals_data = {}
  rows.each do |row|
    children = row.children
    start_times = children[0].text
    day_str = children[1].text
    final_time = children[2].text

    times =  parse( :start_times, start_times )
    day = parse( :day, day_str )
    final_time = parse( :final_time, final_time )
    #puts "=============================="
    #puts "Class Times:  #{times.inspect}"
    #puts "Day: #{day}"
    #puts "Final Time:  #{final_time.inspect}"
    finals_data[day] ||= {}
    times.each do |time|
      finals_data[day][time] = final_time unless time.nil?
    end
  end
  finals_data
end

# Parse class time start cell
def parse_time( time_string, pm )
  if time_string.include?("noon")
    hour = 12
    min = 00
    parsed_time = Time.utc(1990, 7, 1, hour, min)
  elsif time_string.include?("later")
    #TODO: handle this better somehow
    return nil
  else
    time = time_string.match(/(?<hour>\d+):(?<min>\d\d)/)
    hour = time[:hour].to_i
    # Set it to a 24 hour clock
    hour += 12 if pm and hour != 12
    min = time[:min].to_i
    parsed_time = Time.utc(1990, 7, 1, hour, min)
  end
  return parsed_time
end

def parse_day( day )
  case day.strip
    when "Monday" then return :M
    when "Tuesday" then return :T
    when "Wednesday" then return :W
    when "Thursday" then return :R
    when "Friday" then return :F
  end
end

def parse_final_string(data)
  if not data.include?("Arranged")
    final_time_string = data
    parts = final_time_string.split(",")
    time_range = parts[0]
    # Hack: time range splits on "-" but not found sometimes
    time_range[4] = '-'
    time_range = parse( :start_times , time_range ) 

    date = parts[2]
    date = Time.parse(date)

    start_time = Time.utc(1990, date.month, date.day, time_range[0].hour, time_range[0].min)
    end_time = Time.utc(1990, date.month, date.day, time_range[1].hour, time_range[1].min)
    #puts "#{start_time}-#{end_time}"
    return {
      :start_time => start_time,
      :end_time => end_time
    }
  else
    return nil
  end
end

def parse(type, data)
  case type
    when :start_times
      times = data
      pm = data.include?("PM")
      times = times.split(/or|-/)
      results = []
      times.each do |time|
        results << parse_time( time, pm )
      end
      return results
    when :day
      return parse_day( data )
    when :final_time
      return parse_final_string( data )
    else
      puts "Unrecognized type: #{type}"
      return nil
  end
end

init
