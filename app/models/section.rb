class Section < ActiveRecord::Base
  acts_as_list

  has_and_belongs_to_many :games, :join_table => "visible_sections"

  has_many :rooms

#  validates_presence_of :name, :position
  validates_uniqueness_of :name
  validates_numericality_of :position

  def coords(section_position, image_width, image_height, even_sections_count)
    section_x1 = section_position.to_i.odd?  ?  0  :  (image_width / 2).to_i
    section_x2 = section_x1 + (image_width / 2)
    if even_sections_count > 2
      section_y1 = ( (section_position.odd? ? (section_position + 1)/2 - 1 : section_position / 2 - 1) * (image_height / even_sections_count).to_i )
      section_y2 = section_y1 + ( image_height / even_sections_count ).to_i
    else
      section_y1 = 0
      section_y2 = section_y1 + (image_height)
    end
    return "#{section_x1}, #{section_y1}, #{section_x2}, #{section_y2}"
  end
end
