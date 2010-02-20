class MediaObject < ActiveRecord::Base

  
  has_and_belongs_to_many :dialogue_lines

  validates_presence_of :name
  validates_presence_of :short_name
  

  has_attached_file :thumbnail, :styles => {:large=>"121x121#", :medium=>"80x80#", :small=>"30x30#", :tiny=>"12x12#"}
  validates_attachment_presence :thumbnail

end
