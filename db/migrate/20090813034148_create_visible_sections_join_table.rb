class CreateVisibleSectionsJoinTable < ActiveRecord::Migration
  def self.up
    create_table :visible_sections, :id => false do |t|
      t.integer :game_id
      t.integer :section_id
    end
  end

  def self.down
    drop_table :visible_sections
  end
end
