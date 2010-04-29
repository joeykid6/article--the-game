
class GamesController < ApplicationController

  before_filter :authenticate, :except => [:index, :new, :create, :journal]
  before_filter :game_check_then_authenticate, :only => :journal

  # GET /games
  # GET /games.xml
  def index
    @games = Game.all #TODO wrap this for admin view only
    if current_game
      @game = current_game
      @current_room = Room.find(@game.current_room)
      @current_section = Section.find(@current_room.section_id)
    end
    
    respond_to do |format|
      format.html # index.html.erb
#      format.xml  { render :xml => @games }
    end
  end

  # GET /games/1
  # GET /games/1.xml
  def show
    @game = Game.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
#      format.xml  { render :xml => @game }
    end
  end

  # GET /games/new
  # GET /games/new.xml
  def new
    @game = Game.new

    respond_to do |format|
      
        format.html # new.html.erb
#        format.xml  { render :xml => @game }
     
    end
  end

  # GET /games/1/edit
  def edit
    @game = Game.find(params[:id])
  end

  # POST /games
  # POST /games.xml
  def create
    @game = Game.new(params[:game])

    respond_to do |format|
      if @game.save
        
        @starting_section = Section.first(:order => :position)
        @starting_room = @starting_section.rooms.find_by_starting_room(true)

#        If a game already exists, delete it and clear the session
        if current_game
          Game.destroy(current_game)
          reset_session if session
        end

        session[:current_game_id] = @game.id
        
        format.html { redirect_to section_room_path(@starting_section, @starting_room) }
#        format.xml  { render :xml => @game, :status => :created, :location => @game }
      else
        format.html { render :action => "new" }
#        format.xml  { render :xml => @game.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /games/1
  # PUT /games/1.xml
  def update
    @game = Game.find(params[:id])
    


    respond_to do |format|
      if @game.update_attributes(params[:game])
        flash[:notice] = 'Game was successfully updated.'
        format.html { redirect_to(@game) }
#        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
#        format.xml  { render :xml => @game.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.xml
  def destroy
    @game = Game.find(params[:id])
    @game.destroy
    reset_session if session

    respond_to do |format|
      format.html { redirect_to(root_path) }
#      format.xml  { head :ok }
    end
  end

  def journal
    prawnto :inline => false
    prawnto :prawn => {
          :left_margin => 60,
          :right_margin => 48,
          :top_margin => 48,
          :bottom_margin => 48}

    @game = current_game
    @visible_rooms = @game.visible_rooms.order_by_section
    @visible_speakers = Speaker.all(@visible_rooms, :order => :source_name)

    room_count = Room.all.length.to_r
    visible_room_count = @visible_rooms.length.to_r
    @progress = (visible_room_count / room_count * 100).to_f

    render :layout => false
    
  end
end
