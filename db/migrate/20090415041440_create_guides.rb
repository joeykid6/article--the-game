class CreateGuides < ActiveRecord::Migration
  def self.up
    create_table :guides do |t|
      t.string :name #Joseph John Williams or David Fisher
      t.string :short_name #e.g. Dave or Joe

      t.string :thumbnail_file_name
      t.string :thumbnail_content_type
      t.integer :thumbnail_file_size
      t.datetime :thumbnail_updated_at
 
      t.timestamps
    end
  end

  def self.down
    drop_table :guides
  end
end
