require 'redis'

def key(user_id, str)
  "user:#{user_id}:#{str}"
end

redis = Redis.new( :host => 'localhost', :port => 6379 )

users = redis.smembers("user")
users.each do |user|
  puts "user: #{user}"
  friends = redis.smembers( key(user, :friends) )
  friends.each do |friend|
    # Add friendship
    redis.sadd( key(user, :friends), friend )
    redis.sadd( key(friend, :friends), user )
  end
end
