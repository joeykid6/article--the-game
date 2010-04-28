class ChangeSourceNameTypeInSpeakers < ActiveRecord::Migration
  def self.up
    change_column :speakers, :source_name, :text
  end

  def self.down
    change_column :speakers, :source_name, :string
  end
end
