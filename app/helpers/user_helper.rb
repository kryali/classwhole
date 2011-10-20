module UserHelper

  def current_user_has_courses?
    unless current_user and not current_user.courses.empty?
      return false
    else
      return true
    end
  end
end
