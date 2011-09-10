class User < ActiveRecord::Base
  has_many :sections
  has_many :courses
  has_many :friendships

  def friends
    return friendships
  end
end
