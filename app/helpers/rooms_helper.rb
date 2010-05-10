module RoomsHelper
#  For new sections with no rooms: this is the number of blank add room fields in the room_map.
  ROOM_STARTING_NUM = 5

#  Creates a rectangular array to display the locations of all rooms in a given section. The
#  resulting data is meant to be rendered as a table.
  def map_rooms

#    First, we need a new array.
    @room_map = Array.new

#    Now, we need to generate 2D array locations in @room_map for each of the rooms
#    grabbed from the database for this section. @rooms is pulled from the RoomsController
#    index action. We also need to generate the room cell content using the room_td_cell helper.
#    We make sure that @rooms finds records with the unless statement at the end of the loop.
    @rooms.each do |room|
      @room_map[room.row] = Array.new if @room_map[room.row].nil?
      @room_map[room.row][room.col] = room_td_cell(room)
    end unless @rooms.length == 0 #for the case where the section is empty

#    Next, we need to append one row to the end of the array for potentially added rooms.
    @room_map << Array.new

#    Since the iteration through @rooms only creates row arrays where it finds rooms, we need
#    to replace any nils that are inserted with valid row arrays.  Assuming all rooms are connected,
#    there should only be a row at the beginning that could be empty. So it might make more sense
#    to simply set @room_map[0] = Array.new if nil?  But the current technique is below.
    @room_map.map! { |x| (x.nil? ? Array.new : x) }

#    Next, we need to determine the longest row in the 2D array and set all rows to that length
#    (to achieve true tabular data) plus one extra (for potential adding of rooms). We use the
#    fact that we sorted @rooms by the 'col' field in the RoomsController to build a max row length.
#    We're appending nil to indicate empty table cells. The ternary in the until loop checks @rooms for records.
    @room_map.each do |row|
      until row.length == ((@rooms.length == 0) ? ROOM_STARTING_NUM : @rooms.first.col + 2) #set to +2 for extra column.
        row << nil
      end

#      In the next bit, we check if the current cell is nil, then see if it's next to any
#      existing rooms (or the section is empty), and then we generate the "Add Room" link inside.
      row.map! do |x|
        if x.nil? && (is_next_to_room?( @section, @room_map.index(row), row.index(x) ) || (@rooms.length == 0) )
          add_room_td_cell( @room_map.index(row), row.index(x) )
        elsif x.nil? #for cases where there needs to be a cell but no "Add Room" link
          empty_room_td_cell
        else
          x
        end
      end

    end

  end

#  Generates content and tags for each td cell in the room map which contains a room.  Uses
#  attributes of the Room model.
  def room_td_cell(room)
#    SQL calls to retrieve doors
    top_entrance = room.entrances.find_by_door_direction('vertical')
    left_entrance = room.entrances.find_by_door_direction('horizontal')
    bottom_exit = room.exits.find_by_door_direction('vertical')
    right_exit = room.exits.find_by_door_direction('horizontal')

    render :partial => "room", :locals => {
      :room => room,
      :top_entrance => top_entrance,
      :left_entrance => left_entrance,
      :bottom_exit => bottom_exit,
      :right_exit => right_exit
    }
  end

#  Generates wrapper tags for each td cell in the room map which DOES NOT contain a room but needs
#  an "Add Room" link.
  def add_room_td_cell(row, col)
    render :partial => "add_room", :locals => { :row => row, :col => col }
  end

#  Generates wrapper tags for each td cell in the room map which DOES NOT contain a room or an
#  an "Add room" link.
  def empty_room_td_cell
    content_tag( :td, '&nbsp;', :class => 'empty_room' )
  end

#  Generates an image tag for a door, given its direction
#  TODO modify this to include locked/unlocked images?
  def add_door_img(direction, room)
      image_tag("lock-icon.png", :alt => "Door to #{room.name}", :title => "Door to #{room.name}")
  end

#  Decides whether to create a link to add a door, or to display an image representing a door.
  def add_or_link_to_door(section, room, door, direction)

#    Here we call on the row and col fields in the database to assign add door links only where needed.
#    TODO There may be a better way to structure these door cases...  And this should maybe
#    be abstracted to the Room model.
    case direction
    when "top"
      door_direction = "vertical"
      parent_room_id = section.rooms.find_by_row_and_col( (room.row - 1), room.col )
      child_room_id = room.id
    when "left"
      door_direction = "horizontal"
      parent_room_id = section.rooms.find_by_row_and_col( room.row, (room.col - 1) )
      child_room_id = room.id
    when "bottom"
      door_direction = "vertical"
      parent_room_id = room.id
      child_room_id = section.rooms.find_by_row_and_col( (room.row + 1), room.col )
    else #right case
      door_direction = "horizontal"
      parent_room_id = room.id
      child_room_id = section.rooms.find_by_row_and_col( room.row, (room.col + 1) )
    end

    if door.nil?
#      This currently links directly to the create method.  We will need to use the new
#      method again when we have additional door attributes to add.  Probably we'll use AJAX.
#
#      TODO modify this section to include adding doors which lead to other sections of the game.
#      This can be accomplished by parsing the parent_room_id and child_room_id nil cases and pathing to the "new" door view.
#      Or, we could make all the sections self-contained and use an alternative gate that appears when a section is
#      complete.
      link_to "Add door", section_room_doors_path(section, room, :door => {
        :door_direction => door_direction,
        :parent_room_id => parent_room_id,
        :child_room_id => child_room_id
      }), :method => :post unless parent_room_id.nil? || child_room_id.nil?
    else
      link_to(add_door_img(direction, room),
        section_room_door_path(section, room, door),
        :confirm => "Are you sure you want to delete this door?",
        :method => :delete
      )
    end
  end

#  Determines whether a given empty array cell is next to a room in the room map.
  def is_next_to_room?(section, row, col)
    [[(row - 1), col], [row, (col - 1)], [(row + 1), col], [row, (col + 1)]].each do |x|
      return true unless section.rooms.find_by_row_and_col( x[0], x[1] ).nil?
    end
    return false
  end

#  Used for choosing locked versus unlocked icons in compass
  def add_door_img_compass(direction, room, status)
    if status=="locked"
      image_tag("lock-icon.png", :alt => "Door to #{room.name}", :title => "Door to #{room.name}", :class => "door")
    else
      image_tag("door-arrow-#{direction}-unlocked.png", :alt => "Door to #{room.name}", :title => "Door to #{room.name}", :class => "door")
    end
  end

#  Generates the avatar div in the player avatar box
  def avatar_div(avatar)
    html_content = "#{image_tag(avatar.thumbnail.url(:medium))}\n<h3>#{h(truncate(avatar.short_name, :length => 14))}</h3>"
    content_tag :div, :class => avatar.class.to_s.downcase, :id => "#{avatar.class.to_s.downcase}_#{avatar.id}" do
      html_content
    end
  end

#  helper for rendering RJS dialogue lines in start_conversation.rjs
  def render_dialogue_line(avatar, avatar_thumbnail, dialogue_line, fade_in_time, delay = 0)
    page.delay(delay) do
      d_time_stamp = dialogue_time_stamp
      page.insert_html :bottom, 'dialogue_window', :partial => 'dialogue_line', :locals => {
        :avatar => avatar,
        :avatar_thumbnail => avatar_thumbnail,
        :d_time_stamp => d_time_stamp,
        :dialogue_line => dialogue_line }
      page.hide "dialogue_line_#{dialogue_line.id}_#{d_time_stamp}"
      page.visual_effect(:appear, "dialogue_line_#{dialogue_line.id}_#{d_time_stamp}", :duration => fade_in_time)
    end
  end

#  wraps dialogue line content in em tags if it is issued by the game
  def wrap_dialogue(avatar, dialogue_line_content)
    unless avatar.class.to_s == 'GameRobot' && avatar.short_name == 'The Game'
      dialogue_line_content
    else
      content_tag(:em, dialogue_line_content)
    end
  end

#  Sets the delay time for building dialogue sequences in build_conversation.rjs
  def delay_timer_calc(dialogue_line)
    delay_time = case dialogue_line.content.length/30
    when (0..3) then 3
    when (60..1000) then 60
    else
      dialogue_line.content.length/30
    end
    return delay_time
  end

#  Scrolls the dialogue window to the bottom TODO requires cross-browser testing
  def dialogue_scroll_to_bottom(delay, content_length, set_duration = nil)
    if set_duration == nil
      duration = content_length < 90 ? 3 : (content_length/30).to_i #should set duration for now; scriptaculous does not like this
    else
      duration = set_duration
    end
    page.delay(delay) do #delay necessary for proper window height TODO here is where the new livepipe call should go!!
      visual_effect(:scroll, "dialogue_window",
        :queue => {:scope => 'dialogue'},
        :duration => duration,
        :x => 0,
        :y => 0,
        :to_bottom => true)
#      page << 'var objDiv = $("dialogue_window");'
#      page << 'objDiv.scrollTop = 0;' #I believe this is necessary for IE to scroll properly
#      page << 'objDiv.scrollTop = objDiv.scrollHeight;'
    end
  end

#  used to create a timestamp for distinguishing dialogue lines
  def dialogue_time_stamp
    Time.now.strftime("%j%H%M%S")
  end

#  picks the proper css class for dialogue lines based on who says them
  def dialogue_line_class(line_generator_name)
    case line_generator_name
    when "player_response" then "dialogue_line_player"
    when "game_info" then "dialogue_line_game"
    else
      "dialogue_line"
    end
  end

  def is_dialogue_line_long?(dialogue_line)
    true if delay_timer_calc(dialogue_line) >= 6
  end
end