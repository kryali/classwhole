class SchedulerController < ApplicationController

  def index
  end

  def generate_schedules
    scheduler = Scheduler.new(current_user.courses)
    scheduler.schedule_courses
    @possible_schedules = scheduler.valid_schedules
    render 'show'
  end
    
  def show
  end

  def new
    generate_schedules
  end

end
