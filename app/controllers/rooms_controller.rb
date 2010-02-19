require 'RMagick'
class RoomsController < ApplicationController
include Magick
  
  before_filter :authenticate, :except => [:show, :minimap, :section_map, :build_conversation]
  before_filter :game_check_then_authenticate, :only => [:show, :minimap, :section_map, :build_conversation]

  def index
    @section = Section.find(params[:section_id])

#    This order is used by the mini_map method in rooms_helper TODO make this modular
    @rooms = Room.find_all_by_section_id(@section, :order => 'col DESC')
    
    respond_to do |format|
      format.html # index.html.erb
#      format.xml  { render :xml => @rooms }
    end
  end

  def show
    @game = current_game
    @section = Section.find(params[:section_id])
    @next_section = Section.find_by_position(@section.position.to_i + 1)
    @room = Room.find(params[:id])

    
    if @game
#      Store the current room in the game record
#    TODO fix security so that invisible rooms may only be entered legally through their doors (whitelist the door link in the flash)
#    This can probably be fixed with a var attached to the compass links
      @game.update_attributes( :current_room => @room.id )

#    Store the current room and section in their respective join tables unless they're already in there (or if a room is an ending room).
      @game.visible_rooms << @room unless @game.visible_rooms.exists?(@room) || @room.ending_room
      @game.visible_sections << @section unless @game.visible_sections.exists?(@section)

#   If the player has been to this room before, display the media objects she's already looked at.
#   If the same media object appears with several conversations in the room, show it only once.
      @dialogue_lines = @room.dialogue_lines.find(:all)
      @lines_with_objects = @game.visible_dialogue_lines_media_objects.find(:all,
        :conditions => ["dialogue_line_id IN (?)",  @dialogue_lines.map(&:id)])
      @media_objects = MediaObject.find(:all,
        :conditions => ["dialogue_line_id IN (?)", @lines_with_objects.map(&:id)],
        :group => "short_name",
        :joins => :dialogue_lines)

    end

#   Gather visible root lines in room and check whether they belong to Guides or Speakers.
    guide_roots = DialogueLine.visible_at_start.guides_only.conversation_roots(@room)
    speaker_roots = DialogueLine.visible_at_start.speakers_only.conversation_roots(@room)

    @guides = Guide.find(:all, :conditions => ["id IN (?)", guide_roots.map(&:line_generator_id)])
    @speakers = Speaker.find(:all, :conditions => ["id IN (?)", speaker_roots.map(&:line_generator_id)])
    

#    Compass variables
    @top_entrance = @room.entrances.find_by_door_direction('vertical')
    @left_entrance = @room.entrances.find_by_door_direction('horizontal')
    @bottom_exit = @room.exits.find_by_door_direction('vertical')
    @right_exit = @room.exits.find_by_door_direction('horizontal')
    
    my_doors = []

    my_doors << @top_entrance if @top_entrance
    my_doors << @left_entrance if @left_entrance
    my_doors << @right_exit if @right_exit
    my_doors << @bottom_exit if @bottom_exit

    unless my_doors.empty?
      unlocked_doors = Door.find(:all,
        :conditions => [ "id in (?) and game_id= ?", my_doors.map(&:id), @game.id ],
        :joins => "INNER JOIN visible_doors ON visible_doors.door_id = doors.id")

      @open_top = unlocked_doors.include?(@top_entrance)
      @open_left = unlocked_doors.include?(@left_entrance)
      @open_right = unlocked_doors.include?(@right_exit)
      @open_bottom = unlocked_doors.include?(@bottom_exit)
    end

#    The root conversation line in the room--normally a room description. Must create dialogue if it's nil.
    if (@room_root = DialogueLine.room_root(params[:id])).nil?
      flash[:error] = "Please create some dialogue for this room."
    end

    respond_to do |format|
      if @room.ending_room
        format.html { redirect_to(section_path(@next_section)) }
      else
        format.html # show.html.erb
#        format.xml  { render :xml => @room }
      end
    end
  end

  def new
    @room = Room.new
    @section = Section.find(params[:section_id])

    respond_to do |format|
      format.html # new.html.erb
#      format.xml  { render :xml => @room }
    end
  end

  def edit
    @room = Room.find(params[:id])
    @section = Section.find(params[:section_id])
  end

  def create
    @room = Room.new(params[:room])
    @section = Section.find(params[:section_id])

    respond_to do |format|
      if @room.save
        flash[:notice] = 'Room was successfully created.'
        format.html { redirect_to(section_rooms_path(@section)) }
#        format.xml  { render :xml => @room, :status => :created, :location => @room }
      else
        format.html { render :action => "new" }
#        format.xml  { render :xml => @room.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @room = Room.find(params[:id])
    @section = Section.find(params[:section_id])

    respond_to do |format|
      if @room.update_attributes(params[:room])
        flash[:notice] = 'Room was successfully updated.'
        format.html { redirect_to(section_rooms_path(@section)) }
#        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
#        format.xml  { render :xml => @room.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @room = Room.find(params[:id])
    @room.destroy
    @section = Section.find(params[:section_id])

    respond_to do |format|
      format.html { redirect_to(section_rooms_path(@section)) }
#      format.xml  { head :ok }
    end
  end

  def build_conversation
    if request.xhr?
      @game = current_game
      @room = Room.find(params[:room_id]) #generated from _avatar.html.erb or _player_response.html.erb
      @section = Section.find(@room.section_id)

#   This section starts the conversation by determining which conversation roots are visible
#   in the room, and which one to activate at the beginning of a conversation.
#   It is called from _avatar.html.erb.
      if params[:line_generator_id]
        line_generator_id = params[:line_generator_id]
        line_generator_type = params[:line_generator_type]

        @all_root_lines = DialogueLine.conversation_roots(@room)

        @disposed_roots = DialogueLine.find(:all,
          :conditions => ["game_id = ? and dialogue_line_id IN (?)", @game.id, @all_root_lines.map(&:id)],
          :joins => ("INNER JOIN disposed_of_dialogue_lines ON disposed_of_dialogue_lines.dialogue_line_id = dialogue_lines.id"))

        if @disposed_roots.size > 0
          @root_lines = DialogueLine.find(:all,
            :conditions => ["id IN (?) and id NOT IN (?)", @all_root_lines.map(&:id), @disposed_roots.map(&:id)])
        else
          @root_lines = DialogueLine.find(:all,
            :conditions => ["id IN (?) and visible = ?", @all_root_lines.map(&:id), true])
        end

        @dialogue_line = DialogueLine.find(:first,
          :conditions => ["line_generator_id = ? and line_generator_type = ? and id IN (?)",
            line_generator_id,
            line_generator_type,
            @root_lines.map(&:id)])


  #      find the speaker or guide associated with the root dialogue line
        @avatar = @dialogue_line.line_generator
        @avatar_thumbnail = @avatar.thumbnail.url(:small)

      else
#   This section is continuing conversation called from a player response.

        @dialogue_line = DialogueLine.find_by_id(params[:dialogue_line_id])

  #      find the player info and thumbnail to use for the player response posting
        @avatar = @game
        @avatar_thumbnail = @game.thumbnail.url(:small)

      end

#      The next several instance vars are required to update the compass, media objects,
#      and visible root dialogue lines based on the dialogue line being clicked.

#      wraps the media object SQL request in the game dependency so objects won't get drawn
#      or be entered into the visible table if they already exist for this game
      unless @game.visible_dialogue_lines_media_objects.exists?(@dialogue_line)
        @media_objects = @dialogue_line.media_objects
        @game.visible_dialogue_lines_media_objects << @dialogue_line if @media_objects.size > 0
      end

#      TODO I believe this line can be rewritten using the HABTM helper method just like the media_objects
#      SQL request above.
      @doors = Door.find(:all, 
        :conditions => ['dialogue_line_id = ?', @dialogue_line.id],
        :joins => :dialogue_lines)

#      to help reduce door redraws on compass
      @redraw_compass = false

      @doors.each do |door|
        unless @game.visible_doors.exists?(door)
          @game.visible_doors << door
          @redraw_compass = true
        end
      end if @doors.size > 0

      @top_entrance = @room.entrances.find_by_door_direction('vertical')
      @left_entrance = @room.entrances.find_by_door_direction('horizontal')
      @bottom_exit = @room.exits.find_by_door_direction('vertical')
      @right_exit = @room.exits.find_by_door_direction('horizontal')

      my_doors = []

      my_doors << @top_entrance if @top_entrance
      my_doors << @left_entrance if @left_entrance
      my_doors << @right_exit if @right_exit
      my_doors << @bottom_exit if @bottom_exit

      unless my_doors.empty?
        unlocked_doors = Door.find(:all,
          :conditions => [ "id in (?) and game_id= ?", my_doors.map(&:id), @game.id ],
          :joins => "INNER JOIN visible_doors ON visible_doors.door_id = doors.id")

        @open_top = unlocked_doors.include?(@top_entrance)
        @open_left = unlocked_doors.include?(@left_entrance)
        @open_right = unlocked_doors.include?(@right_exit)
        @open_bottom = unlocked_doors.include?(@bottom_exit)
      end
      
      triggered_ids = DialogueLine.find(:all,
        :select => "invisible_dialogue_line_id",
        :from => "visible_dialogue_lines_invisible_dialogue_lines",
        :conditions => ["visible_dialogue_line_id = ?", @dialogue_line.id])

      @triggered_dialogue_lines = DialogueLine.find(:all,
          :conditions => ["id IN (?)",
            triggered_ids.map(&:invisible_dialogue_line_id)]) unless triggered_ids.empty?

    end
  end


#  Ajax updater to move a room via drag and drop.  The params come from the draggable/droppable.
#  TODO This should probably be refactored to be part of the update method.
#  TODO This possibly should be wrapped in a transaction (esp. the door deletion)
  def move_room
    if request.xhr?
      params_id_array = params[:id].split("_")
      @room = Room.find(params_id_array[2])
      entrances = @room.entrances
      exits = @room.exits

      render :update do |page|
        if @room.update_attributes({:row => params[:row], :col => params[:col]})
          entrances.destroy_all unless entrances.length == 0
          exits.destroy_all unless exits.length == 0
        else
          flash[:message] = "There was an error moving the room."
        end
        page.reload
      end
    end
  end

#  This draws and streams the minimap image for the main room interface and the section_map overlay.
#  Default constants are hardcoded for both the minimap and section_map.
  def minimap

#    Color constants for minimap and section_map (both should use the same colors)
    image_border_color =          '#000000'
    room_border_color =           '#000000'
    current_room_fill_color =     '#afafff'
    room_fill_color =             '#ffffff'
    unlocked_door_border_color =  '#000000'
    unlocked_door_fill_color =    '#000000'
    door_border_color =           '#dd0000'
    door_fill_color =             '#dd0000'

#    Size and border constants for minimap and section_map
#    TODO refactor these as constants at the top of the controller and include the references
#    in the section_map view by changing those numbers to instance vars in the section_map method.
#    These should be hard coded because the maps are static for the life of the application
#    and also so that RMagick won't have to query the DB again during a Draw.
#    Use integers for all the sizes.
    if params[:section_map] #this is fed in through a get request in the section_map template
      image_height =      580
      image_width =       580
      image_border =      true
      image_border_size = 1
      room_size =         50
      room_border_width = 1
      room_spacing =      6
      door_size =         18
      filename =          'section_map.png'
    else #minimap case
      image_height =      74
      image_width =       74
      image_border =      false
      room_size =         20
      room_border_width = 1
      room_spacing =      4
      door_size =         8
      filename =          'minimap.png'
    end

#    Instance variables TODO do these need to be instance vars or can they be local?
    @game = current_game
    @section = Section.find(params[:section_id])
    @rooms = Room.find_all_by_section_id(params[:section_id])
    @room = Room.find(params[:id])

#    Local variables
    current_room_usable_row = (@room.row + 1).to_i
    current_room_usable_column = (@room.col + 1).to_i

#    Begin RMagick
    canvas = Magick::Image.new(image_width, image_height, Magick::HatchFill.new('white','lightcyan2',7)) #'#6666cc','#cccc99',18
    canvas.border!( image_border_size, image_border_size, image_border_color ) if image_border

#    TODO refactor to move the following loop into the Room model
#    Draw the rooms and doors, checking to see if a given room is visible in-game
#    Keep in mind that the minimap will not display outside of a game, since no rooms are visible...
    @rooms.each do |room|
      if @game.visible_rooms.exists?(room)
  #      Draw the room rectangle first
        usable_row = (room.row + 1).to_i
        usable_column = (room.col + 1).to_i
        room_x1 = (image_width/2 - room_size/2).to_i - ((current_room_usable_column - usable_column) * (room_size + room_spacing))
        room_y1 = (image_height/2 - room_size/2).to_i - ((current_room_usable_row - usable_row) * (room_size + room_spacing))
        room_x2 = room_x1 + room_size
        room_y2 = room_y1 + room_size

        room_box = Magick::Draw.new

        room_box.stroke(room_border_color)
        room_box.stroke_width(room_border_width)
        room_box.fill(room.id == @room.id ? current_room_fill_color : room_fill_color)
        room_box.fill_opacity(100)
        room_box.rectangle(room_x1, room_y1, room_x2, room_y2)

        room_box.draw(canvas)

  #      Then draw the doors...
  #      Start by constructing door positions for the room using the has_many :through helpers.
        door_positions = Array.new
        door_positions << [(room_x1 + (room_size/2).to_i - (door_size/2).to_i),
          (room_y1 - room_spacing),
          (room_x1 + (room_size/2).to_i + (door_size/2).to_i),
          (room_y1)] if room.entrances.find_by_door_direction('vertical')
        door_positions << [(room_x1 - room_spacing),
          (room_y1 + (room_size/2).to_i - (door_size/2).to_i),
          (room_x1),
          (room_y1 + (room_size/2).to_i + (door_size/2).to_i)] if room.entrances.find_by_door_direction('horizontal')
        door_positions << [(room_x2 - (room_size/2).to_i - (door_size/2).to_i),
          (room_y2),
          (room_x2 - (room_size/2).to_i + (door_size/2).to_i),
          (room_y2 + room_spacing)] if room.exits.find_by_door_direction('vertical')
        door_positions << [(room_x2),
          (room_y2 - (room_size/2).to_i - (door_size/2).to_i),
          (room_x2 + room_spacing),
          (room_y2 + - (room_size/2).to_i + (door_size/2).to_i)] if room.exits.find_by_door_direction('horizontal')

        door_positions.each do |door_position|
          door = Magick::Draw.new

          door.stroke(unlocked_door_border_color)
          door.stroke_width(room_border_width)
          door.fill(unlocked_door_fill_color)
          door.rectangle(*door_position)
          door.draw(canvas)
        end unless door_positions.blank?

      end
    end

    canvas.format = "png"

    send_data canvas.to_blob,
        :filename => filename, #from variables set at the top
        :type => 'img/png',
        :disposition => 'inline'
  end

#  This hooks the minimap method and sends it as a large format map of the whole section with links to other rooms.
  def section_map
    @game = current_game
    @section = Section.find(params[:section_id])
    @room = Room.find(params[:id])
    @rooms = Room.find_all_by_section_id(params[:section_id])

#    Vars for image map links on top of section map
    @current_room_usable_row = (@room.row + 1).to_i
    @current_room_usable_column = (@room.col + 1).to_i
    
    render :layout => false
  end

end
