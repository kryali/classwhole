class UserController < ApplicationController
  def login
    begin 
      @user = User.find(params["userID"])
    rescue ActiveRecord::RecordNotFound
      register(params["accessToken"], params["userID"]);
    ensure
      current_user = @user
      session[:user_id] = @user.id if @user.id
      redirect_to(root_path)
    end
  end

  #
  # register receives an accessToken and a userID, then
  # uses koala to retrieve the user's data 
  # and facebook friends
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
  end


  def logout
    session[:user_id] = nil
    redirect_to(root_path)
  end
end
