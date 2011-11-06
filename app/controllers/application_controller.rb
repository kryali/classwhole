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
		else    
			return nil
    end
  end 

  def current_user=(new_user)
		@current_user = new_user
    session[:user_id] = new_user.id
  end




end
