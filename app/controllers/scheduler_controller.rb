class SchedulerController < ApplicationController

  def index
  end
    
  def show
  end

  def new
    scheduler = Scheduler.new(current_user.courses)
    scheduler.schedule_courses
    @possible_schedules = scheduler.valid_schedules[0,5]
    render 'show'
  end

end
