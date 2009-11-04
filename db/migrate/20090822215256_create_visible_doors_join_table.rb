class CreateVisibleDoorsJoinTable < ActiveRecord::Migration
  def self.up
    create_table :visible_doors, :id => false do |t|
      t.integer :game_id
      t.integer :door_id
    end
  end

  def self.down
    drop_table :visible_doors
  end
end
