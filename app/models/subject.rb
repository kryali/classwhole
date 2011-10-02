class Subject < ActiveRecord::Base
	validates :code, :uniqueness => true
	has_many :courses

  def to_s
    return code
  end

  define_index do
    indexes description, :sortable => true
  end
end
