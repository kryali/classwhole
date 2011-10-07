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

def build_catalog_tries
  puts "Building catalog tries.."
  build_subject_trie
  build_course_trie
end

def build_subject_trie
  $redis.multi do
    Subject.all.each do |subject|
      $redis.sadd("subjects", subject.id)
      $redis.hset("id:subject:#{subject.id}", "label", subject.to_s)
      $redis.hset("id:subject:#{subject.id}", "title", subject.title)
      $redis.hset("id:subject:#{subject.id}", "value", subject.code)
      str = subject.code
      size = str.size

      current_str = ""
      size.times do |i|
        current_str += str[i]
        $redis.sadd("subject:#{current_str}", subject.id)
      end
    end
  end
  puts "Built subject trie."
end

def build_course_trie
  $redis.multi do
    Course.all.each do |course|
      $redis.sadd("courses", course.id)
      $redis.hset("id:course:#{course.id}", "label", course.to_s)
      $redis.hset("id:course:#{course.id}", "title", course.title)
      $redis.hset("id:course:#{course.id}", "value", course.to_s)
      str = course.to_s
      size = str.size

      current_str = ""
      size.times do |i|
        current_str += str[i]
        $redis.sadd("course:#{current_str}", course.id)
      end
    end
  end
  puts "Built course trie."
end

namespace :redis do 
  task :flushdb => [:environment] do
    clear_redis
  end

  task :setup => [:environment, :flushdb] do
    build_catalog_tries
  end
  
  task :seed => [:environment] do
    build_catalog_tries
  end
end
