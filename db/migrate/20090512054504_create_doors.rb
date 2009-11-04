class CreateDoors < ActiveRecord::Migration
  def self.up
    create_table :doors do |t|
      t.references :parent_room
      t.references :child_room
      t.string :door_direction # horizontal or vertical; child rooms are always below or right of parents

      t.timestamps
    end
  end

  def self.down
    drop_table :doors
  end
end
