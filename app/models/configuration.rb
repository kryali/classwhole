class Configuration < ActiveRecord::Base
  belongs_to :course
  has_many :sections

  def sections_hash
    sec_hash = {}
    self.sections.each do |section|
      type = section.section_type
      sec_hash[type] ||= []
      sec_hash[type] << section
    end
    return sec_hash
  end

  def sections_array
    sec_hash = self.sections_hash
    sec_array = sec_hash.sort_by{|k,sections| sections.length}
    for i in 0...sec_array.length
      sec_array[i] = sec_array[i][1]
    end
    return sec_array
  end

end
