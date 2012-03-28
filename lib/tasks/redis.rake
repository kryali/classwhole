# The Trie being built below is for use to respond quickly to autocomplete's AJAX request
# 
# Kiran Ryali - 2011
# 
# How it works: 
# 
# Suppose our input is "C".
# Since "CS" and "CSE" both correspond to the letter C, we want both of those subject ids 
# to match on the "C".
#
# We go through each letter of the input ("CS") and add it to the list of possible hit's for that input.
#  
#     redis.sadd("id:subjects:C", cs.id) # This adds the id to an array at "id:subjects:CH"
#     redis.sadd("id:subjects:CS", cs.id)
#
# or for chemistry:
#
#     redis.sadd("id:subjects:C", chem.id)
#     redis.sadd("id:subjects:CH", chem.id)
#     redis.sadd("id:subjects:CHE", chem.id)
#
# That way we get an O(1) on a search. :-)
#
# This is the mimicked data structure
# http://en.wikipedia.org/wiki/Trie
#
def clear_redis
  $redis.flushdb
end


def delete_keys( pattern )
  $redis.keys( pattern ).each {|key| $redis.del(key)}
end

def clear_subject_trie
  delete_keys( "subjects" )
  delete_keys( "id:subject*" )
  delete_keys( "subject*" )
  puts "Cleared subject trie."
end

def clear_course_trie
  delete_keys( "courses" )
  delete_keys( "id:course*" )
  delete_keys( "course*" )
  puts "Cleared course trie."
end

def clear_catalog_tries
  puts "Clearing catalog tries.."
  clear_subject_trie
  clear_course_trie
end

def build_catalog_tries
  puts "Building catalog tries.."
  build_subject_trie
  build_course_trie
end

def build_subject_trie
  $redis.multi do
    $CURRENT_SEMESTER.subjects.each do |subject|
      # Only add subjects with courses
      if subject.courses.size > 0
        $redis.sadd("subjects", subject.id)
        $redis.hset("id:subject:#{subject.id}", "label", subject.to_s)
        $redis.hset("id:subject:#{subject.id}", "title", subject.title)
        $redis.hset("id:subject:#{subject.id}", "value", subject.code)
        str = subject.code
        size = str.size

        current_str = ""
        size.times do |i|
          current_str += str[i] if str[i] != " "
          $redis.sadd("subject:#{current_str}", subject.id)
        end
      end
    end
  end
  puts "Built subject trie."
end

def build_course_trie
  $redis.multi do
    $CURRENT_SEMESTER.subjects.each do |subject|
      subject.courses.all.each do |course|
        $redis.sadd("courses", course.id)
        $redis.hset("id:course:#{course.id}", "label", course.to_s)
        $redis.hset("id:course:#{course.id}", "title", course.title)
        $redis.hset("id:course:#{course.id}", "hours_min", course.hours_min)
        $redis.hset("id:course:#{course.id}", "hours_max", course.hours_max)
        $redis.hset("id:course:#{course.id}", "value", course.to_s)
        str = course.to_s
        size = str.size

        current_str = ""
        size.times do |i|
          current_str += str[i] if str[i] != " "
          $redis.sadd("course:#{current_str}", course.id)
        end
      end
    end
  end
  puts "Built course trie."
end

def refresh_users
  Course.all.each do |course|
    $redis.del("course:#{course.id}:users")
  end
  puts "Cleared all pre-existing course users"
  #puts "Clearing user redis set"
  #$redis.del("user")
  User.all.each do |user|
    $redis.sadd("user","#{user.id}")
    puts "User added #{user.id}"
    section_ids = $redis.smembers("user:#{user.id}:schedule")
    sections = Section.where( :id => section_ids )
    sections.each do |section|
      puts "SADD course:#{section.course_id}:users, user.id"
      $redis.sadd("course:#{section.course_id}:users", user.id)
      #puts "SREM course:#{course.id}:users, user.id"
      #$redis.srem("course:#{course.id}:users", user.id)
    end
    #refresh_friends( user )
  end
end

def refresh_friends( user )
  key = "user:#{user.id}:friends"
  puts "Using key #{key}"
  friends = $redis.smembers(key)
  if friends
    friends.each do |friend|
      puts "Adding friend #{user.id}-#{friend}"
      user.add_friend( friend )
    end
  else
    puts "#{user.id} has no friends. (didn't save from fb?)"
    puts "#{friends}"
  end
end

namespace :redis do 
  task :flushdb => [:environment] do
    clear_redis
  end

  task :setup => [:environment] do
    clear_catalog_tries
    build_catalog_tries
  end

  task :flushcatalog => [:environment] do
    clear_catalog_tries
  end
  
  task :seed => [:environment] do
    build_catalog_tries
  end

  task :users => [:environment] do
    refresh_users
  end
end
