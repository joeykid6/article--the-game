class Door < ActiveRecord::Base
  belongs_to :parent_room, :class_name => 'Room'
  belongs_to :child_room, :class_name => 'Room'
  has_and_belongs_to_many :dialogue_lines
  has_and_belongs_to_many :games, :join_table => "visible_doors"

  validates_uniqueness_of :parent_room_id, :scope => :door_direction
  validates_uniqueness_of :child_room_id, :scope => :door_direction

end
