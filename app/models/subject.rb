class Subject < ActiveRecord::Base
	validates :code, :uniqueness => true
	has_many :courses

  def self.trie(str)
    subjects = []
    max_results = 10
    possible_subjects = $redis.smembers("subject:#{str.upcase}")
    
    possible_subjects.each do |subject_id|
      label = $redis.hget("id:subject:#{subject_id}", "label")
      title = $redis.hget("id:subject:#{subject_id}", "title")
      value = $redis.hget("id:subject:#{subject_id}", "value")
      subjects << {       label: label,
                          title: title,
                          value: value }
      return subjects if max_results <= 0
      max_results -= 1
    end

    return subjects
  end

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
