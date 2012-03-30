class ProfsController < ApplicationController
  def index
  end

  def show
    @prof = Instructor.decode(params[:name_slug])
    if @prof.nil?
      redirect_to :root 
      return
    end
  end
end
