class DialogueLine < ActiveRecord::Base
  acts_as_nested_set :scope => :room
  validates_presence_of :content
#  validates_uniqueness_of :content  TODO Find out why this is here?

  named_scope :visible_at_start, :conditions => {:visible => true}
  named_scope :guides_only, :conditions => {:line_generator_type => "Guide"}
  named_scope :speakers_only, :conditions => {:line_generator_type => "Speaker"}

# These next two make the necessary associations for has_many_polymorphs
  belongs_to :room
  belongs_to :line_generator, :polymorphic => true


  has_and_belongs_to_many :games, :join_table => "visible_dialogue_lines_media_objects"


  has_and_belongs_to_many :disposed_of_dialogue_lines, :class_name=>"DialogueLine", :join_table => "disposed_of_dialogue_lines",
    :foreign_key=>"game_id",:association_foreign_key=>"dialogue_line_id"
  has_and_belongs_to_many :invisible_dialogue_lines,:class_name=>"DialogueLine", :join_table =>"visible_dialogue_lines_invisible_dialogue_lines",
    :foreign_key=>"visible_dialogue_line_id",:association_foreign_key=>"invisible_dialogue_line_id"

  has_and_belongs_to_many :media_objects
  has_and_belongs_to_many :doors

#  TODO do we really need this? to access the root dialogue line for a whole room
  def self.room_root(room_id)
    find_by_room_id(room_id).root unless find_by_room_id(room_id).nil?
  end
  

#  to access all conversation root dialogue lines in a given room
#  This may not be necessary now that conversation_root is active.
  def self.conversation_roots(room)
    roots.find(:all, :conditions => ["room_id = ?", room.id])
  end

#  TODO currently taking care of this in controller for room with multiple roots
#  to access a particular conversation root dialogue line in a given room
  def self.conversation_root(room)
    conversation_roots(room.id).find_by_line_generator_id_and_line_generator_type(self.line_generator_id, self.line_generator_type)
  end
  
end
