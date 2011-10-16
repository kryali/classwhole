#
# Handles user login/registration interaction
#
class UserController < ApplicationController

  def login
    user_id = params["userID"]
    max_try = 5
    begin 
      @user = User.find(user_id)
      self.current_user=@user
    rescue ActiveRecord::RecordNotFound
      user_id = register(params["accessToken"], params["userID"]);
      max_try -= 1
      retry if max_try > 0
    ensure
      redirect_to(root_path)
    end
  end

  #
  # Description: register receives an accessToken and a userID, then
  #   uses koala to retrieve the user's data and facebook friends
  #
  def register(accessToken, userID)
    # User wasn't found, register him
    @user = User.new
    graph = Koala::Facebook::API.new(accessToken)
    user_data = graph.get_object(userID)
    friends = graph.get_connections(userID, "friends")
    @user.fb_token = accessToken
    @user.id = userID
    @user.name = user_data["name"]
    @user.email = user_data["email"]
    @user.first_name = user_data["first_name"]
    @user.last_name = user_data["last_name"]
    @user.link = user_data["link"]
    @user.gender = user_data["gender"]

    Friendship.transaction do
      friends.each { |friend| Friendship.create(:friend_id => friend["id"], :user_id => userID) }
    end
    
    # Slightly faster redis insertion
    #$redis.multi do
    #  friends.each { |friend| $redis.sadd("#{@user.id}:friends", friend["id"]) }
    #end

    @user.save
    return @user.id
  end

  #
  # destroy the session so the user is no longer logged in
  # delete the cookie 
  def logout
    session[:user_id] = nil
		cookies.delete("classes")
    redirect_to(root_path)
  end

  #
  # Description: This function gets passed a list of course ids and adds it
  #   to the currently logged in user 
  #
  def add_courses
		# If the person isn't logged into facebook, create a cookie
		if !current_user
			cookies["classes"] = { :value => "", :expires => 1.year.from_now }# create a cookie!			
			self.current_user = User.new #create a blank current_user		
		end

		# Add each class to the current users classes
    params["size"].to_i.times do |i|
    	course = params[i.to_s].split(" ")
      subject = course[0]
      number = course[1]
      current_user.courses << Course.find_by_subject_code_and_number(subject, number)
			add_course_to_cookie(subject, number)
    end
		redirect_to(root_path)
  end

  #
  # Description: This function gets passed a course ids and removes the course
  #   from the currently logged in user 
  #
  def remove_course
    begin
      target_course = Course.find(params["course_id"].to_i)
      current_user.courses.delete(target_course)
			remove_class_from_cookie(params["course_id"].to_i)     
			redirect_to(root_path)
    end
  end
	
	#
	#	Description: Helper function to remove a course from the cookie
	#
	#

	def remove_class_from_cookie(id)
		if cookies["classes"]
			id_to_be_removed = id.to_s+ "|"		
			cookies["classes"] = {:value => cookies["classes"].sub(id_to_be_removed, ""), :expires=> 1.year.from_now}
		end	
	end
 #
 # Description: This function simply adds the course_id to a the coookie
 #
 #
	def add_course_to_cookie(subject, number)
		if cookies["classes"]
			course_id_string = Course.find_by_subject_code_and_number(subject, number).id.to_s			
			cook = cookies["classes"] # this is used in the next line, so I didn't have to deal with quotes inside a string		
			cookies["classes"] = { :value => "#{cook}#{course_id_string}|", :expires => 1.year.from_now } 				
		end
	end

end
