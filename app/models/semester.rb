class Semester < ActiveRecord::Base
  has_many :subjects

  def name
    self.season.capitalize + " " + self.year
  end
end
