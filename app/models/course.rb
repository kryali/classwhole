class Course < ActiveRecord::Base
  belongs_to :subject
  has_many :sections
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
      courses << { :label => label,
                   :title => title,
                   :value => value,
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

  def remove_user( user )
    $redis.srem( key(:users), user.id )
  end

  def add_user( user )
    $redis.sadd( key(:users), user.id )
  end

  def key( str )
    "course:#{self.id}:#{str}"
  end

  def configurations
    configs_hash = {}
    sections.each do |section|
      key = section.configuration.key
      type = section.section_type
      configs_hash[key] ||= {}
      configs_hash[key][type] ||= []
      configs_hash[key][type] << section
    end

    configs_array = configs_hash.sort_by{|k,config| k}
    for i in 0...configs_array.length
      configs_array[i] = configs_array[i][1].sort_by{|k,sections| sections.length}
      for j in 0...configs_array[i].length
        configs_array[i][j] = configs_array[i][j][1]
        #configs_array[i][j].sort!{|x,y| x.start_time.to_i <=> y.start_time.to_i}
      end
    end

    return configs_array
  end
end
