module ApplicationHelper
 
# Description: This function returns a list of the class ids
#              that are stored in the cookie
#

 def cookie_class_list    
    class_ids = []    
    if cookies["classes"].nil?
      return class_ids
    end
    class_ids = cookies["classes"].split('|')		
    return class_ids
  end

  def capitalize_first_letter(word)
    ret_string = word[0,1].upcase + word[1..-1] 
    return ret_string
  end

end
