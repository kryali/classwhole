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
end
