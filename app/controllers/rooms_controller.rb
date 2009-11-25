require 'RMagick'
class RoomsController < ApplicationController
include Magick
  
  before_filter :authenticate, :except => [:show, :minimap, :section_map]
  before_filter :game_check_then_authenticate, :only => [:show, :minimap, :section_map]

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

#   If the player has been to this room before, display the media objects she's already looked at.  If the same media object appears with several conversations
#   in the room, show it only once.
      @dialogue_lines = @room.dialogue_lines.find(:all)
      @lines_with_objects = @game.visible_dialogue_lines_media_objects.find(:all, :conditions=> ["dialogue_line_id IN (?)",  @dialogue_lines.map(&:id)])
      @media_objects=MediaObject.find(:all, :conditions=>["dialogue_line_id IN (?)", @lines_with_objects.map(&:id)],:group=>"short_name", :joins=>:dialogue_lines)

      

    end
#    Since the next two variables pull from the DialogueLine association, they create duplicates
#    if a guide or speaker has more than one dialogue line in the room--thus the .uniq method.

#   DF:Adjusting for multiple root lines in room.  Maybe remove game robot message when user enters room?
    @root_lines=DialogueLine.conversation_roots(@room.id)

    @root_lines_visible = DialogueLine.roots.find(:all, :conditions=>["room_id = ? and visible = ?",@room.id, true])

#    DF: The following should be used to identify the seed dialogue line, unless there's another reason a game robot would speak?
#    Still not sure what we're doing with "player response."
#    @game_robot =GameRobot.find(:all, :conditions=>["id IN (?)", @root_lines.map(&:line_generator_id)])



    @guides = Guide.find(:all, :conditions=>["id IN (?)", @root_lines_visible.map(&:line_generator_id)])
    @speakers = Speaker.find(:all, :conditions=>["id IN (?)", @root_lines_visible.map(&:line_generator_id)])


#   TODO  Delete these. See above.  Updated these so that only those avatars who speak root lines appear as conversation starters.
#   @guides = @room.guides.uniq
#   @speakers = @room.speakers.uniq
    

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

    unlocked_doors = Door.find(:all,
      :conditions => [ "id in (?) and game_id= ?", my_doors.map(&:id), @game.id ],
      :joins => "INNER JOIN visible_doors ON visible_doors.door_id = doors.id")

    @open_top = unlocked_doors.include?(@top_entrance)
    @open_left = unlocked_doors.include?(@left_entrance)
    @open_right = unlocked_doors.include?(@right_exit)
    @open_bottom = unlocked_doors.include?(@bottom_exit)
    

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

  def start_conversation
      if request.xhr?
       @game = current_game
     
#      The params used here are from the backend of a drop_receiving_element in show.html.erb
#      DF:  commenting out to make avatar clickable
#
       @room = Room.find(params[:room_id])
       line_generator_id = params[:line_generator_id]
#      params_id_array = params[:id].split("_")

#      line_generator_id = params_id_array[1]
#      line_generator_type = params_id_array[0]


      

      @all_root_lines=DialogueLine.conversation_roots(@room.id)

      @disposed_roots=DialogueLine.find(:all,
        :conditions=>["game_id = ? and dialogue_line_id IN (?)",@game.id, @all_root_lines.map(&:id)],
        :joins=>("INNER JOIN disposed_of_dialogue_lines ON disposed_of_dialogue_lines.dialogue_line_id = dialogue_lines.id"))

      if @disposed_roots.size>0
      @root_lines = DialogueLine.find(:all,
        :conditions=>["id IN (?) and id NOT IN (?)",@all_root_lines.map(&:id), @disposed_roots.map(&:id)])
      else
        @root_lines=DialogueLine.find(:all,
        :conditions=>["id IN (?) and visible = ?",@all_root_lines.map(&:id),true])

      end

      @conversation_root=DialogueLine.find(:first, 
        :conditions=>["line_generator_id = ? and id IN (?)", line_generator_id, @root_lines.map(&:id)])

        #DialogueLine.conversation_root(room_id, line_generator_id, line_generator_type)

#      finding the speaker/guide/media object
      @avatar = @conversation_root.line_generator

#      Store the current conversation avatar DOM id in the session
      session[:avatar_dom_id] = params[:id]

#      RJS replacement for render :partial; this allows multiple page element updates via JS
      render :update do |page|
#        page.hide(params[:id])

        page[:dialogue_speaker_area].replace_html :partial=> 'speaker', :locals=>{:avatar => @avatar}


 #      page[:conversation_starter].replace_html :partial => 'avatar', :locals => {:avatar => @avatar, :room=>@room}

       

        page[:dialogue_lines].visual_effect :opacity, :from => 0, :to => 1, :duration => 1
        page[:dialogue_lines].replace_html :partial => 'dialogue_line', :locals => {
          :avatar => @avatar,
          :dialogue_line => @conversation_root,
          :responses => @conversation_root.children }
        page[:media_objects_div].replace_html ""
      end

#      TODO Update the session and record a single avatar DOM object
#      in the view element "conversationStarter". The session variable should be replaced every time
#      a conversation ends (with NULL) or a new conversation begins (with data on the new avatar).

    end
  end

  #  Generates all dialogue responses to a particular line of dialogue.
  def generate_dialogue
    
    if request.xhr?
      @game = current_game
      @dialogue_line = DialogueLine.find_by_id(params[:id])

      @media_objects=MediaObject.find(:all, :conditions=>['dialogue_line_id = ?', @dialogue_line.id], :joins=>:dialogue_lines)
      @doors=Door.find(:all, :conditions=>['dialogue_line_id = ?', @dialogue_line.id], :joins=>:dialogue_lines)
      @avatar = @dialogue_line.line_generator

      @room = Room.find(:first,:conditions=>["id = ?",@dialogue_line.room_id])
      @section = Section.find(:first,:conditions=>["id = ?",@room.section_id])
      @top_entrance = @room.entrances.find_by_door_direction('vertical')
      @left_entrance = @room.entrances.find_by_door_direction('horizontal')
      @bottom_exit = @room.exits.find_by_door_direction('vertical')
      @right_exit = @room.exits.find_by_door_direction('horizontal')
    
#     (Viewed media objects)Store the current dialogue line in the visible_dialogue_lines_media_objects join table unless it's already in there.
      if @media_objects.size > 0
        @game.visible_dialogue_lines_media_objects << @dialogue_line unless @game.visible_dialogue_lines_media_objects.exists?(@dialogue_line)
      end

      if @doors.size > 0
          @doors.each do |door|
          @game.visible_doors << door unless @game.visible_doors.exists?(door)
        end
      end
      
      
      @triggered_ids=DialogueLine.find(:all,
      :select=>"invisible_dialogue_line_id",
      :from=>"visible_dialogue_lines_invisible_dialogue_lines",
      :conditions=>["visible_dialogue_line_id = ?",@dialogue_line.id])

     
     

      




      render :update do |page|
          page[:compass].replace :partial =>'compass_test', :locals=>{:top_entrance=>@top_entrance,:left_entrance=>@left_entrance,
            :right_exit=>@right_exit,:bottom_exit=>@bottom_exit}

       
          @media_objects.each do |media_object|
           page.insert_html :bottom, :media_objects_div, :partial => 'conversation_media_avatar', :locals=>{:avatar=>media_object}
           end

       
        if @triggered_ids.size>0
     
          @triggered_dialogue_lines =  DialogueLine.find(:all,
            :conditions=>["id IN (?)",@triggered_ids.map(&:invisible_dialogue_line_id)])

          @triggered_dialogue_lines.each do |triggered_line|

          @replaced_dialogue_line=DialogueLine.find(:first,
            :conditions=>["line_generator_id = ? and visible = ? and room_id = ?",triggered_line.line_generator_id, true,@room.id])

           
         @game.disposed_of_dialogue_lines << @replaced_dialogue_line unless @game.disposed_of_dialogue_lines.exists?(@replaced_dialogue_line)
         @avatar_replacement = triggered_line.line_generator

#       TODO the "replacement_avatar" partial (below) is the same as "avatar" with the exctption of style. We can DRY up
#       if we don't see any need to do something else in the partial for the look and feel of a newly triggered root.

            page[triggered_line.line_generator_id.to_s].replace_html :partial => 'replacement_avatar',
            :locals=>{:avatar=>@avatar_replacement, :room=>@room}
        end

  

        
      end



        unless @dialogue_line.children.empty?
          page[:dialogue_lines].replace_html :partial => 'dialogue_line', :locals => {
            :avatar => @avatar,
            :dialogue_line => @dialogue_line,
            :responses => @dialogue_line.children }
          page[:dialogue_speaker_area].replace_html :partial=> 'speaker', :locals=>{:avatar => @avatar}
        else
          

#         page[:media_objects_div].visual_effect :opacity, :from => 1, :to => 0, :duration => 2
#         page[:media_objects_div].replace_html ""
          page[:dialogue_lines].replace_html "End of Conversation"
          page[:dialogue_lines].visual_effect :opacity, :from => 1, :to => 0, :duration => 2
          page[:dialogue_speaker_area].replace_html ""
#         page[:dialogueLines].show

#         page[:conversation_starter].replace_html "Drag stuff here to interact with it."

#         page.delay(0.5) {page[session[:avatar_dom_id]].visual_effect :appear} #TODO set up real handler to return from conversation
        end

      end
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

#    TODO display locked/unlocked doors in different colors from game model
#    TODO refactor to move the following loop into the Room model
#    Draw the rooms and doors, checking to see if a given room is visible in-game
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
