#
# Description:
#   - Controller for the root index page
#
class HomeController < ApplicationController

  caches_page :index

  def index
    render "scheduler/index"
  end

end
