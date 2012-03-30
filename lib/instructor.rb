class Instructor

  attr_accessor :avg, :num_ratings, :easy, :name

  def self.delete_all
    delete_keys("instructor*")
    delete_keys("id:course:*:instructors")
  end
  
  def self.all
    instructors = []
    $redis.smembers("instructors").each { |name| instructors << self.get( name ) }
    return instructors
  end

  def slug
    name.gsub(/,\s/,"-")
  end

  def self.slugify( name )
    slug = name.gsub(/,\s/,"-")
  end

  def self.decode( slug )
    name = slug.gsub(/-/,", ")
    self.get( name )
  end

  # 
  # initializes and returns a requested instructor object
  #
  def self.get( instructor_name )
    if $redis.sismember("instructors", instructor_name )
      # This instructor must exist in our database
      instructor = Instructor.new
      instructor.avg = $redis.get("instructor:#{instructor_name}:avg")
      instructor.easy = $redis.get("instructor:#{instructor_name}:easy")
      instructor.num_ratings = $redis.get("instructor:#{instructor_name}:num_ratings")
      instructor.name = instructor_name
      return instructor
    else
      # We don't have this instructor
      return nil
    end
  end

  def courses
    ret = []
    course_ids = $redis.smembers("instructor:#{self.name}:courses")
    course_ids.each { |id| ret << Course.find( id ) }
    return ret
  end

  def to_s
    name
  end

  #
  # Takes in a name and a course and adds an instructor if it doesnt exist
  #
  def self.add( instructor_name, course )
    $redis.sadd("instructors", instructor_name )
    $redis.sadd("instructor:#{instructor_name}:courses", course.id )
    $redis.sadd("id:course:#{course.id}:instructors", instructor_name )
  end

  #
  # Add a key and a value 
  #
  def self.set( instructor_name, type, rating )
    if not $redis.sismember("instructors", instructor_name )
      $redis.sadd("instructors", instructor_name ) 
    end
    $redis.set("instructor:#{instructor_name}:#{type}", rating)
  end

  # Return instructors that teach a course
  def self.find_all_by_course( course )
    instructors = $redis.smembers("id:course:#{course.id}:instructors")
  end

  #
  # Deletes all keys that match this pattern
  #
  def delete_keys( pattern )
    $redis.keys( pattern ).each {|key| $redis.del(key)}
  end
end
