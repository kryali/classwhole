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
     elsif @current_user #a temp user has already been created
      return @current_user    
    else
      return create_temp_user
    end
  end 

  def current_user=(new_user)
		@current_user = new_user
    session[:user_id] = new_user.id
  end

 # def current_user.is_temp?
 #   return false
 # end

  def create_temp_user
    if cookies["classes"].nil?
      @current_user = Fake_user.new  
    else
      @current_user = Fake_user.new
      for id in cookie_class_list
        begin
          @current_user.courses << Course.find(id)
        rescue ActiveRecord::RecordNotFound
          cookies.delete("classes")
        end
      end
    return @current_user
    end  
  end

  def user_is_temp?
    if !@current_user.is_temp.nil?
      return true  
    else
      return false
    end  
  end

end
