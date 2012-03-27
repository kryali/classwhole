class Fake_user
  def initialize	
    @courses = []
    @@is_temp = 1 
  end  

  def id
    return "nil"
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

  def is_temp?
    return true
  end
end
