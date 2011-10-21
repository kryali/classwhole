module SchedulerHelper

  def hour_range(sections)
    earliest_start_hour = 24 * 60
    latest_end_time = 0
    sections.each do |section|
      current_start_time = section.start_time.hour * 60 + section.start_time.min
      current_end_time = section.end_time.hour * 60 + section.end_time.min

      if current_start_time < earliest_start_hour
        earliest_start_hour = current_start_time
      end
      if current_end_time > latest_end_time
        latest_end_time = current_end_time
      end
    end

    earliest_start_hour = (earliest_start_hour.to_f/60).ceil
    latest_end_hour = (latest_end_time.to_f/60).ceil
    return earliest_start_hour, latest_end_hour
  end

  def section_matrix(sections)
    matrix = Hash.new

    sections.each do |section|
      days = section.days.split("")
      days.each do |day|
        matrix[day] = Array.new unless matrix[day]
      end
    end
    
    return matrix
  end

end
