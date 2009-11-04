class CreateDialogueLinesMediaObjects < ActiveRecord::Migration
  def self.up
    create_table :dialogue_lines_media_objects, :id => false do |t|
      t.integer :dialogue_line_id
      t.integer :media_object_id
    end
  end

  def self.down
    drop_table :dialogue_lines_media_objects
  end
end
