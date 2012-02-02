class CreateGenedsAttributesRelationship < ActiveRecord::Migration
  def up
    create_table :geneds_attributes, :id => false do |t|
      t.integer :geneds_id
      t.integer :attributes_id
    end
  end

  def down
    drop_table :geneds_attributes
  end
end
