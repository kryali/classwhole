class User < ActiveRecord::Base
  has_many :sections
  has_many :courses
  has_many :friendships
end
