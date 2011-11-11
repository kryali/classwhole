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

  def total_course_hours
    hours = 0
    @courses.each do |course|
      hours += course.hours 
    end
    return hours
  end


  def is_temp?
    return true
  end
end
