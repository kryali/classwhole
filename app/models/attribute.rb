class Attribute < ActiveRecord::Base
  has_many_and_belongs_to :geneds
end
