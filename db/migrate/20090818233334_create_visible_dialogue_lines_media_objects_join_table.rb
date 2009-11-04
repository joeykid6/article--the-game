class CreateVisibleDialogueLinesMediaObjectsJoinTable < ActiveRecord::Migration
  def self.up
    create_table :visible_dialogue_lines_media_objects, :id => false do |t|
      t.integer :game_id
      t.integer :dialogue_line_id
    end
  end

  def self.down
    drop_table :visible_dialogue_lines_media_objects
  end
end