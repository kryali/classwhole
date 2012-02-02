class Meeting < ActiveRecord::Base
  has_one :building
  belongs_to :section
end
