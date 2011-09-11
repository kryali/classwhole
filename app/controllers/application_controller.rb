class ApplicationController < ActionController::Base
  protect_from_forgery

  protected
  attr_accessor :current_user

  def current_user
    unless session[:user_id]
      # If there is no session, no user is logged in
      return nil
    else
      # Else, we must have a user, so return it
      begin
        @current_user = @current_user || User.find(session[:user_id])
        return @current_user
      rescue
        return nil
      end
    end
  end

  def current_user=(user)
    @current_user = user 
    session[:user_id] = user.id
  end

end
