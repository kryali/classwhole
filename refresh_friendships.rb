require 'redis'

def user_key(user_id, str)
  "user:#{user_id}:#{str}"
end

def course_key( course_id, str )
  "course:#{course_id}:#{str}"
end

redis = Redis.new( :host => 'localhost', :port => 6379 )

users = redis.smembers("user")
users.each do |user|
  puts "user: #{user}"
  
  # Refresh friendships
  friends = redis.smembers( user_key(user, :friends) )
  friends.each do |friend|
    # Add friendship
    redis.sadd( user_key(user, :friends), friend )
    redis.sadd( user_key(friend, :friends), user )
  end
end
