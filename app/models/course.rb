class Course < ActiveRecord::Base
  belongs_to :subject
  has_many :sections
  has_many :configurations
  has_and_belongs_to_many :geneds
  has_and_belongs_to_many :users
  set_primary_key :id

  def self.trie(term)
    results_needed = 100

    begin
      possible_courses = $redis.smembers("course:#{term.upcase.gsub(/\s+/,"")}")
    rescue Errno::ECONNREFUSED
      return nil
    end

    courses = []
    possible_courses.each do |course_id|
      results_needed -= 1
      break if results_needed <= 0

      label = $redis.hget("id:course:#{course_id}", "label")
      title = $redis.hget("id:course:#{course_id}", "title")
      value = $redis.hget("id:course:#{course_id}", "value")
      min_hours = $redis.hget("id:course:#{course_id}", "hours_min")
      max_hours = $redis.hget("id:course:#{course_id}", "hours_max")
      courses << { :label => label,
                   :title => title,
                   :value => value,
                   :min_hours => min_hours,
                   :max_hours => max_hours,
                   :id =>    course_id }
    end
    return courses 
  end

  def user_ids
    user_ids = $redis.smembers( key( :users ) )
  end

  def users
    users = []
    User.transaction do
      self.user_ids.each do |user_id|
        begin
          users << User.find( user_id )
        rescue ActiveRecord::RecordNotFound
          return users
        end
      end
    end
    users.sort_by { rand }
  end

  def to_s
    subject_code + " " + number.to_s
  end

  def key( str )
    "course:#{self.id}:#{str}"
  end

  def credit_hours
    return "" if hours_min.nil? or hours_max.nil?
    if hours_min - hours_max != 0
      "#{hours_min}-#{hours_max}"
    else
      "#{hours_min}"
    end
  end

  def hours
    "#{credit_hours} hr"
  end

  def semester
    subject.semester
  end

end
