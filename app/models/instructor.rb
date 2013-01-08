class Instructor < ActiveRecord::Base
  has_and_belongs_to_many :meetings
  
  attr_accessor :avg, :num_ratings, :easy, :name

  def self.slugify( name )
    slug = name.gsub(/,\s/,"-")
  end

  def self.decode( slug )
    name = slug.gsub(/-/,", ")
    self.get( name )
  end

  def print_courses
    ret = ""
    courses.each do |course|
      ret = "#{ret}#{course.to_s} "
    end
    return ret
  end

  def to_s
    name
  end

  def slug
    name.gsub(/,\s/,"-")
  end
end
