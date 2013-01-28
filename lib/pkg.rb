#
# Packages database objects for delivery to clients via JSON
#
class Pkg
  def self.section(section)
    section_pkg = {
      id: section.id,
      course_id: section.course_id,
      type: section.short_type_s,
      code: section.code,
      crn: section.reference_number,
      enrollment: section.enrollment_status,
      reason: section.reason,
      group: {
        id: section.group.id,
        key: section.group.key,
      },
      meetings: []
    }
    section.meetings.each do |meeting| 
      section_pkg[:meetings] << { 
        :duration => meeting.duration_s,
        :start_time => simple_time(meeting.start_time),
        :end_time => simple_time(meeting.end_time),
        :days => meeting.days,
        :instructor => meeting.instructors[0]
      }
    end
    return section_pkg
  end

  def self.course(course)
    course_pkg = {
      id: course.id,
      name: course.to_s,
      subjectCode: course.subject_code,
      number: course.number
    }
    course_pkg[:sections] = course.sections.map{|section| Pkg.section(section)}
    return course_pkg
  end
end
