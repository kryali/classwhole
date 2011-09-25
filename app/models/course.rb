class Course < ActiveRecord::Base
  belongs_to :subject
  has_many :sections
  has_many :announcements
#   has_and_belongs_to_many :users

  def to_s
    return subject_code + " " + number.to_s
  end
end
