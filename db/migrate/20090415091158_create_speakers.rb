class CreateSpeakers < ActiveRecord::Migration
  def self.up
    create_table :speakers do |t|
      t.string :name #full, properly punctuated name of all authors
      t.string :short_name #e.g. Wolf et al, or Blair and Simonson
      t.string :title #name of work being cited
      t.string :source_name #if it's from a journal, anthology, or some other larger work
      t.string :source_type #what kind of citation is it? book, journal article, webpage, etc.
      t.string :url #if the source is online and has a URL


      t.string :thumbnail_file_name
      t.string :thumbnail_content_type
      t.integer :thumbnail_file_size
      t.datetime :thumbnail_updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :speakers
  end
end
