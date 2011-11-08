#
# Description:
#   - Controller for the root index page
#
class HomeController < ApplicationController
  include ApplicationHelper

  def index
    render "scheduler/index"
  end

end
