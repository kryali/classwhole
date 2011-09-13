class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user

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
