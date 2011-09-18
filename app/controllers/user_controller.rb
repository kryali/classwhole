#
# Handles user login/registration interaction
#
class UserController < ApplicationController

  def login
    user_id = params["userID"]
    begin 
      @user = User.find(user_id)
      self.current_user=@user
    rescue ActiveRecord::RecordNotFound
      user_id = register(params["accessToken"], params["userID"]);
      retry
    ensure
      redirect_to(root_path)
    end
  end

  #
  # Description: register receives an accessToken and a userID, then
  #   uses koala to retrieve the user's data 
  #   and facebook friends
  #
  def register(accessToken, userID)
    # User wasn't found, register him
    @user = User.new
    graph = Koala::Facebook::API.new(accessToken)
    user_data = graph.get_object(userID)
    friends = graph.get_connections(userID, "friends")
    friends.each { |friend| Friendship.create(:friend_id => friend["id"], :user_id => userID) }
    @user.fb_token = accessToken
    @user.id = userID
    @user.name = user_data["name"]
    @user.email = user_data["email"]
    @user.first_name = user_data["first_name"]
    @user.last_name = user_data["last_name"]
    @user.link = user_data["link"]
    @user.gender = user_data["gender"]
    @user.save
    return @user.id
  end

  #
  # destroy the session so the user is no longer logged in
  #
  def logout
    session[:user_id] = nil
    redirect_to(root_path)
  end

  #
  # Description: This function gets passed a list of course ids and adds it
  #   to the currently logged in user 
  #
  def add_courses
    # Add each class to the current users classes
    params["size"].to_i.times { |i| current_user.courses << Course.find(params[i.to_s]) }
    redirect_to(root_path)
  end

end
