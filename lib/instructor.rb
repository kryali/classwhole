class Instructor

  def delete_keys( pattern )
    $redis.keys( pattern ).each {|key| $redis.del(key)}
  end

  def self.delete_all
    delete_keys("instructor*")
    delete_keys("id:course:*:instructors")
  end
  
  def self.all
    $redis.smembers("instructors")
  end

  #
  # Takes in a name and a course and adds an instructor if it doesnt exist
  #
  def self.add( instructor_name, course )
    $redis.sadd("instructors", instructor_name )
    $redis.sadd("id:course:#{course.id}:instructors", instructor_name )
  end

  def self.add_rating( instructor_name, type, rating )
    $redis.set("instructors:#{instructor_name}:#{type}", rating)
  end

  def self.find_by_course( course )
    instructors = $redis.smembers("id:course:#{course.id}:instructors")
  end

end
