class SchedulerController < ApplicationController

  def index
  end

  def has_conflicts?(schedule, target_section)
    schedule.each do |section|
      return true if section.conflict?(target_section)
    end
    return false
  end

  def generate_schedule
    schedule = []
    logger.info "START SCHEDULER"
    current_user.courses.each do |course|
      logger.info "Course: #{course.to_s}"
      course.sections.each do |section|
        if not has_conflicts?(schedule, section)
          schedule << section
          break
        end
      end
    end
    render :json => schedule
  end

  def show
  end

  def new
    generate_schedule
  end

end
