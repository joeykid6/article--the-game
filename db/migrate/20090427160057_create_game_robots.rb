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
  end

  def self.down
    drop_table :game_robots
  end
end
