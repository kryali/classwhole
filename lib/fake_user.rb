class Fake_user
  def initialize(cookies)
    @store = CookieArrayStore.new(cookies)
    data = Fake_user.get_saved_data(cookies)
    @courses = data[:courses]
    @schedule = data[:schedule]
  end

  def save_courses(courses)
    ids = []
    courses.each {|course| ids << course.id}
    @store.set(:courses, ids)
  end

  def courses=(new_courses)
    save_courses(new_courses)
    @courses = new_courses
  end

  def rem_course(course)
    @store.delete(:courses, course.id)
    @courses.delete(course)
  end


  def add_course(course)
    @store.add(:courses, course.id)
    @courses << course
  end

  def courses
    return @courses
  end

  def min_hours
    hours = 0
    @courses.each {|course| hours += course.hours_min }
    return hours
  end

  def max_hours
    hours = 0
    @courses.each {|course| hours += course.hours_max }
    return hours
  end

  def total_course_hours
    if min_hours - max_hours != 0
      "#{min_hours}-#{max_hours}"
    else
      "#{max_hours}"
    end
  end

  def save
    save_courses(@courses)
    save_schedule(@schedule)
  end

  def is_temp?
    return true
  end

  def schedule
    return @schedule
  end

  def save_schedule(schedule)
    ids = []
    schedule.each {|section| ids << section.id}
    @store.set(:schedule, ids)
  end

  def schedule=(new_schedule)
    save_schedule(new_schedule)
    @schedule = new_schedule
  end

  def self.get_saved_data(cookies)
    store = CookieArrayStore.new(cookies)
    courses = CookieArrayStore.read_array(:courses, Course, store)
    schedule = CookieArrayStore.read_array(:schedule, Section, store)
    return {:courses => courses, :schedule => schedule}
  end

  def self.clear_data(cookies)
    store = CookieArrayStore.new(cookies)
    store.clear(:courses)
    store.clear(:schedule)
  end
end

class CookieArrayStore

  def clear(key)
    @cookies.delete(key)
  end

  def initialize(cookies)
    @cookies = cookies
  end
  
  def add(key, obj)
    saved = get(key)
    saved << obj
    set(key, saved)
  end

  def delete(key, obj)
    saved = get(key)
    saved.delete(obj)
    set(key, saved)
  end

  def get(key)
    saved = []
    if @cookies[key].nil?
      set(key, saved)
    else
      saved = Marshal.load(@cookies[key])
    end
    return saved
  end

  def set(key, obj)
    @cookies[key] = {:value  => Marshal.dump(obj), :expires => 1.day.from_now}
  end

  def self.read_array(key, model, store)
    values = []
    ids = store.get(key)
    ids.each do |id|
      begin
        values << model.find(id)
      rescue ActiveRecord::RecordNotFound
        values = []
        store.set(key, value)
        return values
      end
    end
    return values
  end
end
