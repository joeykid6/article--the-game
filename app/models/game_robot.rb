class GameRobot < ActiveRecord::Base
#  new way with has_many_polymorphs
#  nothing needed
has_attached_file :thumbnail, :styles => {:large=>"121x121#", :medium=>"80x80#", :small=>"30x30#", :tiny=>"12x12#"}
  validates_attachment_presence :thumbnail
end
