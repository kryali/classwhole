class UserController < ApplicationController
  def login
#    render :text => params
    @user = User.find(params["id"])
    session[:user_id] = @user.id if @user.id
    redirect_to(root_path)
=begin
    @user = User.find_by_fb_id(params["id"])
    unless @user
      @user = User.new
      @user.first_name = params["first_name"]
      @user.last_name = params["last_name"]
      @user.tj
    end
=end 
  end

  def register
    @user = User.find(params["userID"])
    current_user = @user
    session[:user_id] = @user.id if @user.id
    if not @user
      @user = User.new
      graph = Koala::Facebook::API.new(params["accessToken"])
      user_data = graph.get_object(params["userID"])
      friends = graph.get_connections(params["userID"], "friends")
      friends.each do |friend|
        Friendship.create(:friend_id => friend["id"], :user_id => params["userID"])
      end
      @user.fb_token = params["accessToken"]
      @user.id = params["userID"]
      @user.name = user_data["name"]
      @user.email = user_data["email"]
      @user.first_name = user_data["first_name"]
      @user.last_name = user_data["last_name"]
      @user.link = user_data["link"]
      @user.gender = user_data["gender"]
      @user.save
    end
    redirect_to(root_path)
  end

  def logout
    session[:user_id] = nil
    redirect_to(root_path)
  end
end
