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
  delete_keys( "subject*" )
  puts "Cleared subject trie."
end

def clear_course_trie
  delete_keys( "courses" )
  delete_keys( "course*" )
  puts "Cleared course trie."
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


#
# HACK: For some reason, 
#       we the users in courses, 
#       so we do this extra step to (hopefully) fix it
#
def add_users_to_courses
  User.all.each do |user|
    user.courses.each { |course| course.add_user(user) }
  end
  puts "Updated users"
end

namespace :redis do 
  task :clear_catalog => [:environment] do
    clear_subject_trie
    clear_course_trie
    puts "Cleared all tries"
  end

  task :users => [:environment] do
    refresh_users
  end
end
