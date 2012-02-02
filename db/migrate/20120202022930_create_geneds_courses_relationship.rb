class CreateGenedsCoursesRelationship < ActiveRecord::Migration
  def up
    create_table :geneds_courses, :id => false do |t|
      t.integer :geneds_id
      t.integer :courses_id
    end
  end

  def down
    drop_table :geneds_courses
  end
end
