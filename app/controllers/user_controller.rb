class UserController < ApplicationController
  def login
    render :text => params
=begin
    @user = User.find_by_fb_id(params["id"])
    unless @user
      @user = User.new
      @user.first_name = params["first_name"]
      @user.last_name = params["last_name"]
      @user.tj
    end
    {"id"=>"1342020220", "name"=>"Kiran Ryali", "first_name"=>"Kiran", "last_name"=>"Ryali", "link"=>"https://www.facebook.com/kiranryali", "username"=>"kiranryali", "gender"=>"male", "timezone"=>"-5", "locale"=>"en_US", "verified"=>"true", "updated_time"=>"2011-09-07T05:27:25+0000", "controller"=>"user", "action"=>"login"}
=end 
  end

  def register
    @user = User.find_by_fb_id(params["userID"])
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
      render :text => "Finished"
    end
=begin
{"id"=>"1342020220", "name"=>"Kiran Ryali", "first_name"=>"Kiran", "last_name"=>"Ryali", "link"=>"http://www.facebook.com/kiranryali", "username"=>"kiranryali", "gender"=>"male", "timezone"=>-5, "locale"=>"en_US", "verified"=>true, "updated_time"=>"2011-09-07T05:27:25+0000"}
"accessToken"=>"AAACNYJFTeXgBACKHmy2tZABsForq2c2H6yYsk77xLuPnD4nzEp5bEMt5yjiuKiVENB3xZB4KchecZA4T7M3ZBdCX5ptZCUZAk5jbUZAquKSQVQpJNDA8uM3", "userID"=>"1342020220", "expiresIn"=>"7185", "signedRequest"=>"F8NbZKlFvsMuFK23B8YsxVszf-_9zlIzePGO1uk_axE.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImNvZGUiOiJBUUM5OE5BeVU3d25LQ000dURvZTJydTdrTnRUb2NjRDgySzNDQmwzeVk4NUVKOUFyME11b0ZGd3B0MEFFSDZmVlJYam56RzUxVFpOMmpiWHdyU3o2QS0xMHFVUmNHMGhKRFplcV9kV0pMLUw3bUdWX1F6ZmI4cFpzZmxLd2psbzZnd3NreXRFUzlOVWxfSWE4NlVOOEI5c01QQWF1UGhfSWdoTGIxVWdVV1pwUnR5MjRFcnBRYnpjWnRrUWpfVzRHX2MiLCJpc3N1ZWRfYXQiOjEzMTU2MzgwMTUsInVzZXJfaWQiOiIxMzQyMDIwMjIwIn0", "controller"=>"user", "action"=>"register"}
=end
  end
end
