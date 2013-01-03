module ApplicationHelper
  def capitalize_first_letter(word)
    ret_string = word[0,1].upcase + word[1..-1] 
    return ret_string
  end

  def fb_img_link( user, type = "large" ) 
    "https://graph.facebook.com/#{user.fb_id}/picture?type=#{type}"
  end
end
