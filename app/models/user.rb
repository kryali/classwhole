class User < ActiveRecord::Base
  has_many :sections
  has_many :courses
  has_many :friendships

  def after_initialize
    $redis.sadd("user", self.id)
  end

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

    # Clear your old schedule out of the users list
    schedule_ids = $redis.smembers( redis_key(:schedule) )
    old_sections = Section.where( :id => schedule_ids )
    old_sections.each do |section|
      $redis.srem("course:#{section.course_id}:users", section.course_id)
    end

    # Remove all your current courses and sync them with the new schedule
    courses.delete_all
    $redis.del( self.redis_key(:schedule) )
    sections.each do |section_id|
      $redis.sadd( self.redis_key(:schedule), section_id.to_i)
      course = Section.find( section_id.to_i ).course
      course.add_user( self )
      courses << course unless courses.include?(course)
    end
  end

  def friend_ids
    # find the intersection of the user list and this users friends list
    friend_ids = $redis.sinter( self.redis_key(:friends), "user" )
  end

  # Return the friends of this user
  def friends
    # find the intersection of the user list and this users friends list
    friend_ids = $redis.sinter( self.redis_key(:friends), "user" )
    User.where( :id => friend_ids )
  end

  def add_friends_fb( friends )
    $redis.multi do
      friends.each do |friend| 
        # Build the two way relationship, even if the new friend isn't in our db
        # because maybe they will come later.
        $redis.sadd(self.redis_key(:friends), friend["id"])
        $redis.sadd("user:#{friend["id"]}:friends", self.id)
      end
    end
  end

  def add_friend( friend_id )
    $redis.sadd(self.redis_key(:friends), friend_id)
    $redis.sadd( "user:#{friend_id}:friends" , self.id)
  end

  def rem_course( course )
    course.remove_user( self )
    self.courses.delete( course )
  end

  def owns
    if gender == "male"
      "his"
    elsif gender == "female"
      "her"
    else
      "a"
    end
  end

  def redis_key( str )
    return "user:#{self.id}:#{str}"
  end

end
