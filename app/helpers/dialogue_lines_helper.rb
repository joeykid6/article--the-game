module DialogueLinesHelper

  def add_door_img_dl(direction, room)
    image_tag "door-arrow-#{direction}.gif", :alt => "Door to #{room.name}", :title => "Door to #{room.name}"
  end

  def add_door_img_dl_small(direction, room)
    image_tag "door-arrow-#{direction}-small.gif", :alt => "Door to #{room.name}", :title => "Door to #{room.name}"
  end

end
