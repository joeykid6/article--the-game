class CreateVisibleDialogueLinesInvisibleDialogueLinesJoinTable < ActiveRecord::Migration
  def self.up
    create_table :visible_dialogue_lines_invisible_dialogue_lines, :id => false do |t|
      t.integer :visible_dialogue_line_id
      t.integer :invisible_dialogue_line_id
    end
  end

  def self.down
    drop_table :visible_dialogue_lines_invisible_dialogue_lines
  end
end
