class ModalController < ApplicationController
  include ApplicationHelper

  def modal
    render params["modal"], :locals => params["locals"], :layout => false
  end

end
