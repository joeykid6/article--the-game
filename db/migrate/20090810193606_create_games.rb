class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|

#     This is the player name, but to make it match the other avatars in the
#     abstract dialogue_line code, we used "short_name" instead
      t.string :short_name
     
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
