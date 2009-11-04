class CreateDialogueLinesDoors < ActiveRecord::Migration
  def self.up
    create_table :dialogue_lines_doors, :id => false do |t|
      t.integer :dialogue_line_id
      t.integer :door_id
    end
  end

  def self.down
    drop_table :dialogue_lines_doors
  end
end
