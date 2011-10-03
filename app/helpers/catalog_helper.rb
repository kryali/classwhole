module CatalogHelper

  # Description: 
  #   This helper method returns a javascript formatted array of classes
  #   for use with jquery-ui's autocomplete
  #
  # todo: cache this list of classes
  # notes: kinda ghetto but w/e
  def course_list_for_autocomplete
    course_list = "["
    Course.all.each do |course|
      course_list+="{label:\"#{course.subject_code+" "+course.number.to_s}\",title:\"#{course.title}\",value:\"#{course.id}\"},\n"
    end
    course_list += "]"
  end

  # Description: 
  #   This helper method returns a javascript formatted array of subjects
  #   for use with jquery-ui's autocomplete
  #
  def subject_list_for_autocomplete
    subject_list = "["
    all_subjects do |subject|
      subject_list+="{label:\"#{subject.to_s}\",title:\"#{subject.title}\",value:\"#{subject.code}\"},\n"
        subject_list << { label: "#{subject.to_s}",
                          title: "#{subject.title}",
                          value: "#{subject.code}" }
    end
    subject_list += "]"
  end

  def all_subjects
    @all_subjects ||= Subject.all
  end

end
