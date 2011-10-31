class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user



  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end


  # This looks weird to me.. I'll look at this again when I don't suck at ruby
  protected
  def current_user    
		if session[:user_id]     	
			return @current_user ||= User.find(session[:user_id])
    elsif cookies["classes"]        #if they're not in the database, but have a cookie for classwhole
			return temp_current_user 	
		else    
			return nil
    end
  end 

  def current_user=(new_user)
		if cookies["classes"]		
			@current_user = User.new
		end
		@current_user = new_user
    session[:user_id] = new_user.id
  end

	#
	# Description: Function to create a temporary current_user for non-facebook users
	#  			

	def temp_current_user
		#if we already have made a temp current user, just return that one		
		if @current_user
				return @current_user
		end
		# otherwise, create a temp current_user based on the cookie
    # that holds the users class id's 		
		@current_user = User.new		
		class_ids = cookies["classes"].split('|')		
		class_ids.each do |id|
			@current_user.courses << Course.find(id.to_i)
		end
		return @current_user	
	end


end
