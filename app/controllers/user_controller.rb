#
# Handles user login/registration interaction
#
class UserController < ApplicationController
  include ApplicationHelper

  def login
    user_id = params["userID"]
    begin 
      @user = User.find(user_id)
    rescue #ActiveRecord::RecordNotFound # Sometimes we get a SQLException?
      @user = register(params["accessToken"], params["userID"])
    ensure
      self.current_user=@user

      # if there is a cookie, overwrite any courses in db
      saved_data = Fake_user.get_saved_data(cookies)
      @user.courses = saved_data[:courses] if saved_data[:courses].any?
      @user.schedule = saved_data[:schedule] if saved_data[:schedule].any?
      Fake_user.clear_data(cookies)
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
    #logger.info "Starting registration for #{userID}"
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
    
    @user.save

    if @user.nil?
      logger.info "ERROR!"
      logger.info "#{userID}" if @user.nil?
      logger.info user_data.inspect if @user.nil?
    else
      logger.info "#{userID} successfully registered"
    end

    return @user  
  end

 
 def logout
   session[:user_id] = nil
   cookies.delete("classes")
   redirect_to(root_path)
 end

end
