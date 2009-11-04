class CreateRooms < ActiveRecord::Migration
  def self.up
    create_table :rooms do |t|
      t.string :name
      t.integer :row
      t.integer :col
      t.boolean :starting_room, :default => 0
      t.boolean :ending_room, :default => 0
      t.references :section
      
      t.timestamps
    end
  end

  def self.down
    drop_table :rooms
  end
end
