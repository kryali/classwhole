class Subject < ActiveRecord::Base
	validates :code, :uniqueness => true
	has_many :courses

  def self.trie(str)
    #subjects = []
    #possible_subjects = $redis.smembers("subject:#{str}")
    #possible_subjects.each do |subject_id|
    #  subjects << Subject.find(subject_id)
    #end
    #return subjects
    #logger.info "REDIS!!!"
    #result = $redis.smembers("subject:#{str}")
    #logger.info "#{str}:#{result}"
    #return result
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
