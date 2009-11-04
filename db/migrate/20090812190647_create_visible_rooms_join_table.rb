class CreateVisibleRoomsJoinTable < ActiveRecord::Migration
  def self.up
    create_table :visible_rooms, :id => false do |t|
      t.integer :game_id
      t.integer :room_id
    end
  end

  def self.down
    drop_table :visible_rooms
  end
end
