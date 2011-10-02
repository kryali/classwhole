class Subject < ActiveRecord::Base
	validates :code, :uniqueness => true
	has_many :courses

  def starts_with?(str)
    str.size.times do |i|
      return false unless code[i] == str[i]
    end
    return true
  end

  def to_s
    return code
  end

  define_index do
    indexes description, :sortable => true
  end
end
