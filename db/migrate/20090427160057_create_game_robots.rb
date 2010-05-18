class CreateGameRobots < ActiveRecord::Migration
  def self.up
    create_table :game_robots do |t|
      t.string :name
      t.string :short_name

      t.string :thumbnail_file_name
      t.string :thumbnail_content_type
      t.integer :thumbnail_file_size
      t.datetime :thumbnail_updated_at

      t.timestamps
    end
 #TODO deal with images-->because model validates presence of a thumbnail, these seeds won't be inserted

    seed = GameRobot.create(:name => 'game_info',:short_name=>'The Game')
    seed.save
    seed = GameRobot.create(:name => 'player_response',:short_name=>'The Player')
    seed.save
    seed = GameRobot.create(:name => 'object_info',:short_name=>'The Object')
    seed.save


  end

  def self.down
    drop_table :game_robots
  end
end
