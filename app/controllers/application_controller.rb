class ApplicationController < ActionController::Base
  include ApplicationHelper

  protect_from_forgery
  helper_method :current_user

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  protected
  def current_user    
    if @current_user.nil?
      if session[:user_id]
        @current_user ||= User.find(session[:user_id])
      else
        @current_user = Fake_user.new(cookies)
      end
    end
    return @current_user
  end 

  def current_user=(new_user)
		@current_user = new_user
    session[:user_id] = new_user.id
  end
end
