class AddSourceNameToMediaObjects < ActiveRecord::Migration
  def self.up
    add_column :media_objects, :source_name, :text
  end

  def self.down
    remove_column :media_objects, :source_name
  end
end
