class Subject < ActiveRecord::Base
	validates :code, :uniqueness => true
	has_many :courses

  define_index do
    indexes description, :sortable => true
  end
end
