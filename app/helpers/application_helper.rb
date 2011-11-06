module ApplicationHelper
  def cookie_class_list    
    class_ids = []    
    if cookies["classes"].nil?
      return class_ids
    end
    class_ids = cookies["classes"].split('|')		
    return class_ids
  end

end
