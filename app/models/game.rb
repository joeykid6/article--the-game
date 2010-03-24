class Game < ActiveRecord::Base
# This is the Game model used to store all player and game state info.
  has_and_belongs_to_many :disposed_of_dialogue_lines, :class_name => "DialogueLine", :join_table => "disposed_of_dialogue_lines",
    :foreign_key=>"game_id",:association_foreign_key=>"dialogue_line_id"
  has_and_belongs_to_many :visible_dialogue_lines_media_objects, :class_name => "DialogueLine", :join_table => "visible_dialogue_lines_media_objects"
  has_and_belongs_to_many :visible_doors, :class_name => "Door", :join_table => "visible_doors"
  has_and_belongs_to_many :visible_rooms, :class_name => "Room", :join_table => "visible_rooms"
  has_and_belongs_to_many :visible_sections, :class_name => "Section", :join_table => "visible_sections"

  has_attached_file :thumbnail, :styles => {:large=>"121x121#", :medium=>"80x80#", :small=>"30x30#", :tiny=>"12x12#"},
    :default_url => "/images/player-blank.jpg"
  #validates_attachment_presence :thumbnail
  
  validates_presence_of :short_name

  def before_save
    self.short_name=Sanitize.clean(self.short_name)
  end

end
