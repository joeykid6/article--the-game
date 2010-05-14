class MediaObject < ActiveRecord::Base

  
  has_and_belongs_to_many :dialogue_lines

  validates_presence_of :name
  validates_presence_of :short_name
  

  has_attached_file :thumbnail, 
    :styles => {:large=>"121x121#", :medium=>"80x80#", :small=>"30x30#", :tiny=>"12x12#"},
    :url => "/system/:class/:attachment/:id/:style/:basename.:extension",
    :path => ":rails_root/public/system/:class/:attachment/:id/:style/:basename.:extension"


  validates_attachment_presence :thumbnail

  def before_save
    self.source_name = Sanitize.clean(self.source_name, :elements => ['a','strong','em','u','i'],
      :attributes => {'a' => ['href']},
      :protocols => {'a' => {'href' => ['http', 'https']}})
  end

end
