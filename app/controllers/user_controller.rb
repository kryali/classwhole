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
    render :text => params
  end
end
