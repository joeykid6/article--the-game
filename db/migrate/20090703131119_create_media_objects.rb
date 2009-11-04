class CreateMediaObjects < ActiveRecord::Migration
  def self.up
    create_table :media_objects do |t|
      t.string :name
      t.string :short_name

      

      t.string :thumbnail_file_name
      t.string :thumbnail_content_type
      t.integer :thumbnail_file_size
      t.datetime :thumbnail_updated_at
  
      t.text :url

      t.integer :object_width
      t.integer :object_height

      t.timestamps
    end
  end

  def self.down
    drop_table :media_objects
  end
end
