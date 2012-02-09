class Meeting < ActiveRecord::Base
  belongs_to :building
  belongs_to :section
  has_and_belongs_to_many :instructors
end
