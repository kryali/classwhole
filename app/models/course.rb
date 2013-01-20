class Course < ActiveRecord::Base
  belongs_to :subject
  has_many :sections
  has_many :groups
  has_and_belongs_to_many :geneds
  has_and_belongs_to_many :users
  set_primary_key :id

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
