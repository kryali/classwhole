class Course < ActiveRecord::Base
  belongs_to :subject
  has_many :sections
  has_many :announcements
#   has_and_belongs_to_many :users

  def self.trie(term)
    courses = []
    possible_courses = $redis.smembers("course:#{term}")
    possible_courses.each do |course_id|
      label = $redis.hget("id:course:#{course_id}", "label")
      title = $redis.hget("id:course:#{course_id}", "title")
      value = $redis.hget("id:course:#{course_id}", "value")
      courses << {       label: label,
                          title: title,
                          value: value }
    end
    return courses
  end

  def to_s
    return subject_code + " " + number.to_s
  end
end
