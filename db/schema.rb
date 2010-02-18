# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100218181628) do

  create_table "dialogue_generators", :force => true do |t|
    t.string   "generator_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dialogue_lines", :force => true do |t|
    t.text     "content"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "line_generator_id"
    t.string   "line_generator_type"
    t.integer  "room_id"
    t.boolean  "visible",             :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dialogue_lines_doors", :id => false, :force => true do |t|
    t.integer "dialogue_line_id"
    t.integer "door_id"
  end

  create_table "dialogue_lines_media_objects", :id => false, :force => true do |t|
    t.integer "dialogue_line_id"
    t.integer "media_object_id"
  end

  create_table "disposed_of_dialogue_lines", :id => false, :force => true do |t|
    t.integer "game_id"
    t.integer "dialogue_line_id"
  end

  create_table "doors", :force => true do |t|
    t.integer  "parent_room_id"
    t.integer  "child_room_id"
    t.string   "door_direction"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "game_robots", :force => true do |t|
    t.string   "name"
    t.string   "short_name"
    t.string   "thumbnail_file_name"
    t.string   "thumbnail_content_type"
    t.integer  "thumbnail_file_size"
    t.datetime "thumbnail_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "games", :force => true do |t|
    t.string   "short_name"
    t.string   "thumbnail_file_name"
    t.string   "thumbnail_content_type"
    t.integer  "thumbnail_file_size"
    t.datetime "thumbnail_updated_at"
    t.integer  "current_room"
    t.boolean  "finished",               :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "guides", :force => true do |t|
    t.string   "name"
    t.string   "short_name"
    t.string   "thumbnail_file_name"
    t.string   "thumbnail_content_type"
    t.integer  "thumbnail_file_size"
    t.datetime "thumbnail_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "line_generators", :force => true do |t|
    t.string   "line_generator_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "media_objects", :force => true do |t|
    t.string   "name"
    t.string   "short_name"
    t.boolean  "image_object",           :default => false
    t.string   "thumbnail_file_name"
    t.string   "thumbnail_content_type"
    t.integer  "thumbnail_file_size"
    t.datetime "thumbnail_updated_at"
    t.text     "url"
    t.integer  "object_width"
    t.integer  "object_height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rooms", :force => true do |t|
    t.string   "name"
    t.integer  "row"
    t.integer  "col"
    t.boolean  "starting_room", :default => false
    t.boolean  "ending_room",   :default => false
    t.integer  "section_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sections", :force => true do |t|
    t.string   "name"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "speakers", :force => true do |t|
    t.string   "name"
    t.string   "short_name"
    t.string   "title"
    t.string   "source_name"
    t.string   "source_type"
    t.string   "url"
    t.string   "thumbnail_file_name"
    t.string   "thumbnail_content_type"
    t.integer  "thumbnail_file_size"
    t.datetime "thumbnail_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "visible_dialogue_lines_invisible_dialogue_lines", :id => false, :force => true do |t|
    t.integer "visible_dialogue_line_id"
    t.integer "invisible_dialogue_line_id"
  end

  create_table "visible_dialogue_lines_media_objects", :id => false, :force => true do |t|
    t.integer "game_id"
    t.integer "dialogue_line_id"
  end

  create_table "visible_doors", :id => false, :force => true do |t|
    t.integer "game_id"
    t.integer "door_id"
  end

  create_table "visible_rooms", :id => false, :force => true do |t|
    t.integer "game_id"
    t.integer "room_id"
  end

  create_table "visible_sections", :id => false, :force => true do |t|
    t.integer "game_id"
    t.integer "section_id"
  end

end
