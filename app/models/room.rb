class Room < ActiveRecord::Base
  #The Room class is the equivalent of a journal article sub-section

#  Generates minimap or section map coordinates for this room relative to a "current" room
  def coords(current_room_usable_row, current_room_usable_column, image_height, image_width, room_size, room_spacing)
    usable_row = (self.row + 1).to_i
    usable_column = (self.col + 1).to_i
    room_x1 = (image_width/2 - room_size/2).to_i - ((current_room_usable_column - usable_column) * (room_size + room_spacing))
    room_y1 = (image_height/2 - room_size/2).to_i - ((current_room_usable_row - usable_row) * (room_size + room_spacing))
    room_x2 = room_x1 + room_size
    room_y2 = room_y1 + room_size
    return "#{room_x1}, #{room_y1}, #{room_x2}, #{room_y2}"
  end

  has_and_belongs_to_many :games, :join_table => "visible_rooms"


  before_update :delete_doors_on_section_move

  validates_presence_of :name, :row, :col, :section_id
  validates_uniqueness_of :name, :scope => :section_id
  validates_uniqueness_of :starting_room, :scope => :section_id, :if => Proc.new { |game| game.starting_room == true }
  validates_uniqueness_of :ending_room, :scope => :section_id, :if => Proc.new { |game| game.ending_room == true }
  validates_uniqueness_of :row, :scope => [:col, :section_id], :message => "and column already taken in this section"
  validates_numericality_of :row, :col

  #  Using has_many_polymorphs to create DialogueLine relationships.

  has_many_polymorphs :line_generators,
    :from => [:game_robots, :guides, :speakers],
    :through => :dialogue_lines,
    :dependent => :destroy

#  Entrances are always from the top and left (following Western reading conventions)
  has_many :entrances,
    :foreign_key => :child_room_id, #this room is the child in relation to its entrances
    :class_name => 'Door',
    :dependent => :destroy

  has_many :parent_rooms,  :through => :entrances


#  Exits are always toward the bottom and right (again, following Western reading conventions)
  has_many :exits,
    :foreign_key => :parent_room_id, #this room is the parent in relation to its exits
    :class_name => 'Door',
    :dependent => :destroy

  has_many :child_rooms,  :through => :exits

  

#  Each room belongs to a section of the game/article
  belongs_to :section


  private
  def delete_doors_on_section_move
    if self.section_id_changed?
      self.entrances.delete_all
      self.exits.delete_all
    end
  end
end