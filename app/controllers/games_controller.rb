class GamesController < ApplicationController

  before_filter :authenticate, :except => [:index, :new, :create]

  # GET /games
  # GET /games.xml
  def index
    @games = Game.all #TODO wrap this for admin view only
    if current_game
      @game = Game.find(current_game)
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
    @game_avatars=GameAvatar.find(:all)

    respond_to do |format|
      format.html # new.html.erb
#      format.xml  { render :xml => @game }
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
          reset_session
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
    reset_session

    respond_to do |format|
      format.html { redirect_to(root_path) }
#      format.xml  { head :ok }
    end
  end
end
