#
# Handles user login/registration interaction
#
class UserController < ApplicationController
include ApplicationHelper

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
		  cookies.delete("classes")
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

    #if they added some classes obefore logging in...
    for id in cookie_class_list
      logger.info(id.to_s)
      logger.info("PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP")
      @user.courses << Course.find(id)
    end
    logger.info("XXXXXDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD")
    @user.save
    return @user.id  
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
		if !current_user and cookies["classes"].nil?
			cookies["classes"] = { :value => "", :expires => 1.year.from_now }# create a cookie!			
		#	self.current_user = User.new #create a blank current_user		
		end
		# Add each class to the current users classes
    if current_user
      current_user.courses << Course.find( params["id"].to_i )
    else
      add_course_to_cookie( params["id"] )
    end
		render :json => { :status => "success", :message => "Class added" }
	 end

  #
  # Description: This function gets passed a course ids and removes the course
  #   from the currently logged in user 
  #
  def remove_course
    begin
      target_course = Course.find(params["course_id"].to_i)
      if current_user      
        current_user.courses.delete(target_course)
      else			
        remove_class_from_cookie(params["course_id"].to_i)     
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
			cookies["classes"] = {:value => cookies["classes"].sub(id_to_be_removed, ""), :expires=> 1.year.from_now}
		end	
	end
 #
 # Description: This function simply adds the course_id to a the coookie
 #
 #
	def add_course_to_cookie(id)
		if cookies["classes"]
			course_id_string = id.to_s			
			cook = cookies["classes"] # this is used in the next line, so I didn't have to deal with quotes inside a string		
			cookies["classes"] = { :value => "#{cook}#{course_id_string}|", :expires => 1.year.from_now } 				
		end
	end


end
