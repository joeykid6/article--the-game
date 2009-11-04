class GameAvatarsController < ApplicationController
  # GET /game_avatars
  # GET /game_avatars.xml
  def index
    @game_avatars = GameAvatar.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @game_avatars }
    end
  end

  # GET /game_avatars/1
  # GET /game_avatars/1.xml
  def show
    @game_avatar = GameAvatar.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @game_avatar }
    end
  end

  # GET /game_avatars/new
  # GET /game_avatars/new.xml
  def new
    @game_avatar = GameAvatar.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @game_avatar }
    end
  end

  # GET /game_avatars/1/edit
  def edit
    @game_avatar = GameAvatar.find(params[:id])
  end

  # POST /game_avatars
  # POST /game_avatars.xml
  def create
    @game_avatar = GameAvatar.new(params[:game_avatar])

    
      if @game_avatar.save
        render :partial=>"save_result"

      else
        flash[:message] = "There was an error saving the game avatar."
      end
  end

  # PUT /game_avatars/1
  # PUT /game_avatars/1.xml
  def update
    @game_avatar = GameAvatar.find(params[:id])

    respond_to do |format|
      if @game_avatar.update_attributes(params[:game_avatar])
        flash[:notice] = 'GameAvatar was successfully updated.'
        format.html { redirect_to(@game_avatar) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @game_avatar.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /game_avatars/1
  # DELETE /game_avatars/1.xml
  def destroy
    @game_avatar = GameAvatar.find(params[:id])
    @game_avatar.destroy

    respond_to do |format|
      format.html { redirect_to(game_avatars_url) }
      format.xml  { head :ok }
    end
  end
end
