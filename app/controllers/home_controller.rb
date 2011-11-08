#
# Description:
#   - Controller for the root index page
#
class HomeController < ApplicationController
  include ApplicationHelper
  before_filter :set_cache_buster

  def index
    render "scheduler/index"
  end

end
