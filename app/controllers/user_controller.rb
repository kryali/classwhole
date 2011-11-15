#
# Handles user login/registration interaction
#
class UserController < ApplicationController
include ApplicationHelper

  def login
    user_id = params["userID"]
    begin 
      @user = User.find(user_id)
    rescue ActiveRecord::RecordNotFound
      @user = register(params["accessToken"], params["userID"])
    ensure
      self.current_user=@user
      if !cookies["classes"].nil? #if there is a cookie, overwrite any courses in db
        @user.courses.delete_all        
        for id in cookie_class_list
          @user.courses << Course.find(id)
          end   
        cookies.delete("classes")  
      end
      @status = "success"
      @message = "Logged in"
      render :partial => 'shared/user_nav', :layout => false
    end
  end

  #
  # Refreshes course list when user initially logs into facebook
  #
  def refresh
    render :partial => 'scheduler/user_course_list', :layout => false
  end


  #
  # Takes care of displaying the header with page caching
  #

  def header
    is_temp = current_user.is_temp?
    render :json => {:is_temp => is_temp}
   #render action => 'shared/header'  
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
    @user.fb_id = userID
    @user.name = user_data["name"]
    @user.email = user_data["email"]
    @user.first_name = user_data["first_name"]
    @user.last_name = user_data["last_name"]
    @user.link = user_data["link"]
    @user.gender = user_data["gender"]

    #Friendship.transaction do
    #  friends.each { |friend| Friendship.create(:friend_id => friend["id"], :user_id => userID) }
    #end
    
    # Slightly faster redis insertion
    $redis.multi do
      friends.each { |friend| $redis.sadd("user:#{@user.id}:friends", friend["id"]) }
    end
    @user.save
    return @user  
  end

 
 def logout
   session[:user_id] = nil
   cookies.delete("classes")
   redirect_to(root_path)
 end

  

  #
  # Description: This function gets passed a list of course ids and adds it
  #   to the currently logged in user 
  #
  # We should probably be looking up the id instead of doing a slow search here
  #
  def add_course
		# If the person isn't logged into facebook, create a cookie, but don't overwrite it
    if cookies["classes"].nil? and current_user.is_temp?
		  cookies["classes"] = { :value => "", :expires => 1.day.from_now }			
    end

    begin 
      course_id = params["id"].to_i
      course = Course.find( course_id )
      if current_user.courses.include?(course) 
        render :json => { :status => "error", :message => "Class already added" }
        return
      else
        course_users = current_user.courses.to_json
        current_user.courses << course
        if current_user.is_temp?
          add_course_to_cookie( params["id"] )
        else
        course.add_user( current_user )
        end
        render :json => { :status => "success", :message => "Class added", :users => course_users }
      end
    rescue ActiveRecord::RecordNotFound
        render :json => { :status => "error", :message => "Class not found" }
    end
  end


  #
  # Description: This function gets passed a course ids and removes the course
  #   from the currently logged in user 
  #
  def remove_course
    begin
      target_course = Course.find(params["course_id"].to_i)
      if current_user.is_temp?		
        remove_class_from_cookie(params["course_id"].to_i)     
      else
        current_user.rem_course( target_course )
      end			
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
			cookies["classes"] = {:value => cookies["classes"].sub(id_to_be_removed, ""), :expires=> 1.day.from_now}
		end	
	end
 #
 # Description: This function simply adds the course_id to a the coookie
 #
 #
	def add_course_to_cookie(id)
		if cookies["classes"]
      logger.info(id)
			course_id_string = id.to_s			
			cook = cookies["classes"] # this is used in the next line, so I didn't have to deal with quotes inside a string		
			cookies["classes"] = { :value => "#{cook}#{course_id_string}|", :expires => 1.day.from_now } 				
		end
	end

end
