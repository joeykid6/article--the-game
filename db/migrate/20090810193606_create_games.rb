class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|
      t.string :player_name
     
      t.integer :game_avatar_id

      t.integer :current_room
      t.boolean :finished, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :games
  end
end
