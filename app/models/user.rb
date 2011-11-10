class User < ActiveRecord::Base
  has_many :sections
  has_many :courses
  has_many :friendships

  def friends
    friends = []
    friendships.each do |friendship|
      begin
        friend = User.find(friendship.friend_id)
        friends << friend if friend
      rescue ActiveRecord::RecordNotFound
        # friend not found
      end
    end
    return friends
  end

  def total_course_hours
    hours = 0
    courses.each do |course|
      hours += course.hours 
    end
    return hours
  end

  def is_temp?
    return false
  end

  def schedule
    sections = []
    section_ids = $redis.smembers("user:#{id}:schedule")
    section_ids.each do |section_id|
      sections << Section.find( section_id )
    end
    return sections
  end

  # add_schedule takes in a list of section ids 
  # and adds them to the redis database
  def add_schedule( sections )
    redis_key  ="user:#{id}:schedule"
    $redis.del(redis_key)
    sections.each do |section_id|
      $redis.sadd(redis_key, section_id.to_i)
    end
  end

end
