class Gened < ActiveRecord::Base
  has_and_belongs_to_many :attribs
  has_and_belongs_to_many :courses
end
