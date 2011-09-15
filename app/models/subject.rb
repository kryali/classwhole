class Subject < ActiveRecord::Base
	validates :subjectCode, :uniqueness => true
	has_many :courses

  define_index do
    indexes subjectDescription, :sortable => true
    has :subjectCode
  end
end
