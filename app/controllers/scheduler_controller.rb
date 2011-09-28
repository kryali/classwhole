class SchedulerController < ApplicationController
  def index
  end

  # Description: This function ensures that no two sections are conflicting
  #   Method: Make sure that sectionb's start and end time is not between sectiona's start and end time
  def conflict?(sectiona, sectionb)
  end

  def generate_schedule
    schedule = []
    logger.info "START SCHEDULER"
    current_user.courses.each do |course|
      logger.info "Course: #{course.to_s}"
      course.sections.each do |section|
        logger.info "\tSection: #{section.code}"
        logger.info "\t\tTime: #{section.start_time} #{section.end_time}"
        logger.info "\t\tType: #{section.code}"
      end
    end
    logger.info "END SCHEDULER"
  end

  def show
    generate_schedule
  end

end
