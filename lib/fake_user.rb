class Fake_user
  def initialize(cookies)
    @cookies = cookies
    @courses = []
    @@is_temp = 1 
  end  
  def id
    return "nil"
  end

  def courses=(new_courses)
    courses = new_courses
  end

  def rem_course(course)
    remove_class_from_cookie( course.id )     
  end


  def add_course( course )
    add_course_to_cookie( course.id )
    courses << course
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
	
	#
	#	Description: Helper function to remove a course from the cookie
	#
	#

	def remove_class_from_cookie(id)
		if @cookies["classes"]
			id_to_be_removed = id.to_s+ "|"		
			@cookies["classes"] = {:value => @cookies["classes"].sub(id_to_be_removed, ""), :expires=> 1.day.from_now}
		end	
	end
 #
 # Description: This function simply adds the course_id to a the coookie
 #
 #
	def add_course_to_cookie(id)
		if @cookies["classes"]
      #logger.info(id)
			course_id_string = id.to_s			
			cook = @cookies["classes"] # this is used in the next line, so I didn't have to deal with quotes inside a string		
			@cookies["classes"] = { :value => "#{cook}#{course_id_string}|", :expires => 1.day.from_now } 				
		end
	end

end
