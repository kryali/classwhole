class User < ActiveRecord::Base
  has_many :friendships
  has_and_belongs_to_many :courses
  has_and_belongs_to_many :schedule, :class_name => "Section"
  set_primary_key :id

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

  def min_hours
    hours = 0
    courses.each {|course| hours += course.hours_min if not course.hours_min.nil? }
    return hours
  end

  def max_hours
    hours = 0
    courses.each {|course| hours += course.hours_max if not course.hours_max.nil? }
    return hours
  end

  def total_course_hours
    return "" if min_hours.nil? or max_hours.nil?
    if min_hours - max_hours != 0
      "#{min_hours}-#{max_hours}"
    else
      "#{max_hours}"
    end
  end

  def is_temp?
    return false
  end

  #TODO
  def friend_ids
    return []
  end

  #TODO # Return the friends of this user
  def friends
    return []
  end

  # TODO
  def add_friends_fb(friends)
  end

  # TODO
  def add_friend(friend_id)
  end

  def rem_course(course)
    self.courses.delete(course)
  end

  def add_course(course)
    self.courses << course
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
end
