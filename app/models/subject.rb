class Subject < ActiveRecord::Base
	has_many :courses
  belongs_to :semester

  def self.minify(subjects)
    payload = []
    subjects.all.each do |subject|
      payload << {
                    :title => subject.title,
                    :value => subject.code,
                    :label => subject.to_s,
                    :id => subject.id,
      }
    end
    return payload
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

  def mini_courses
    payload = []
    courses.each do |course|
      payload << {
        :id => course.id,
        :title => course.title,
        :course => course.to_s,
        :label => course.to_s,
        :hours_min => course.hours_min,
        :hours_max => course.hours_max,
      }
    end
    return payload
  end
end
