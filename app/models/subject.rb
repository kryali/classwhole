class Subject < ActiveRecord::Base
	validates :code, :uniqueness => true
	has_many :courses
  belongs_to :semester

  def self.mini_all
    return self.trie( "", true )
  end

  def self.trie(str, return_all=false)
    begin
      if return_all
        possible_subjects = $redis.smembers("subjects")
      else
        possible_subjects = $redis.smembers("subject:#{str.upcase.gsub(/\s+/, "")}")
      end
    rescue Errno::ECONNREFUSED
      return nil
    end
    
    subjects = []
    if return_all
      max_results = 9999999
    else
      max_results = 100
    end
    possible_subjects.each do |subject_id|
      label = $redis.hget("id:subject:#{subject_id}", "label")
      title = $redis.hget("id:subject:#{subject_id}", "title")
      value = $redis.hget("id:subject:#{subject_id}", "value")
      subjects << {       :label => label,
                          :title => title,
                          :value => value }
      max_results -= 1
      break if max_results <= 0
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

end
