class CreateDisposedOfDialogueLinesJoinTable < ActiveRecord::Migration
  def self.up
    create_table :disposed_of_dialogue_lines, :id => false do |t|
      t.integer :game_id
      t.integer :dialogue_line_id
    end
  end

  def self.down
    drop_table :disposed_of_dialogue_lines
  end
end
