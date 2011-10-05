class Subject < ActiveRecord::Base
	validates :code, :uniqueness => true
	has_many :courses

  def self.trie(str)
    subjects = []
    possible_subjects = $redis.smembers("subject:#{str}")
    possible_subjects.each do |subject_id|
      label = $redis.hget("id:subject:#{subject_id}", "label")
      title = $redis.hget("id:subject:#{subject_id}", "title")
      value = $redis.hget("id:subject:#{subject_id}", "value")
      subjects << {       label: label,
                          title: title,
                          value: value }
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
