class Configuration < ActiveRecord::Base
  belongs_to :course
  has_many :sections

  attr_accessor :sections_hash, :sections_array

  def sections_hash
    if @sec_hash.nil?
      init_sections_hash
    end
    return @sec_hash
  end

  def sections_array
    if @sec_array.nil?
      init_sections_array
    end
    return @sec_array
  end

  def init_sections_hash
    @sec_hash = {}
    self.sections.each do |section|
      type = section.short_type
      @sec_hash[type] ||= []
      @sec_hash[type] << section
    end
  end

  def init_sections_array
    sec_hash = self.sections_hash
    @sec_array = sec_hash.sort_by{|k,sections| sections.length}
    for i in 0...@sec_array.length
      @sec_array[i] = @sec_array[i][1]
    end
  end

end
