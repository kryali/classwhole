#
# Description:
#   - Controller for the root index page
#
class HomeController < ApplicationController

  caches_page :index

  def index
    redirect_to scheduler_index_path
  end

end
