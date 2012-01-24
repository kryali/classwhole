#
# Description:
#   - Controller for the root index page
#
class HomeController < ApplicationController
  include ApplicationHelper

  def index
    redirect_to scheduler_index_path
  end

  def careers
  end

  def about
  end

end
