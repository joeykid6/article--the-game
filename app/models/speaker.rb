class Speaker < ActiveRecord::Base
  # This class acts more like an in-text citation than a speaker. In
  # theory, we could create a complete bibliography system,
  # but it doesn't make sense unless we think we are going to
  # use the same database for several articles or for a book-like game.
  # 
  # We should create a separate class for media objects, rather than
  # trying to fit them into this one. There should be people to talk
  # to and objects to examine in each room.

  # Dialogue for the speaker in a given room...

#  new way with has_many_polymorphs
#  nothing needed

  validates_presence_of :name
  validates_presence_of :short_name
  validates_presence_of :title
  validates_presence_of :source_name
  has_attached_file :thumbnail, :styles => {:large=>"121x121#", :medium=>"80x80#", :small=>"30x30#", :tiny=>"12x12#"}
  validates_attachment_presence :thumbnail
end
