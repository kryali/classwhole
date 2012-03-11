class Semester < ActiveRecord::Base
  has_many :subjects

  def name
    self.season + " " + self.year
  end
end
