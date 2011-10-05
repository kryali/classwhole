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
    @user.fb_token = accessToken
    @user.id = userID
    @user.name = user_data["name"]
    @user.email = user_data["email"]
    @user.first_name = user_data["first_name"]
    @user.last_name = user_data["last_name"]
    @user.link = user_data["link"]
    @user.gender = user_data["gender"]

    Friendship.transaction do
      friends.each { |friend| Friendship.create(:friend_id => friend["id"], :user_id => userID) }
    end
    
    # Slightly faster redis insertion
    #$redis.multi do
    #  friends.each { |friend| $redis.sadd("#{@user.id}:friends", friend["id"]) }
    #end

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
    params["size"].to_i.times do |i|
      course = params[i.to_s].split(" ")
      subject = course[0]
      number = course[1]
      current_user.courses << Course.find_by_subject_code_and_number(subject, number)
    end
    redirect_to(root_path)
  end

  #
  # Description: This function gets passed a course ids and removes the course
  #   from the currently logged in user 
  #
  def remove_course
    begin
      target_course = Course.find(params["course_id"].to_i)
      current_user.courses.delete(target_course)
      redirect_to(root_path)
    end
  end

end
