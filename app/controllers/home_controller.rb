class HomeController < ApplicationController

  def index
    @current_user = current_user
  end

  #autocomplete :subject, :subjectCode, :full => false
end
