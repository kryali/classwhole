def clear_redis
  $redis.flushdb
end

def build_catalog_tries
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
end

namespace :redis do 
  task :flushdb => [:environment] do
    clear_redis
  end

  task :setup => [:environment, :flushdb] do
    puts "Building catalog tries.."
    build_catalog_tries
  end
end
