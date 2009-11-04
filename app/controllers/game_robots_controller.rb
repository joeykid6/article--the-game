class GameRobotsController < ApplicationController

  before_filter :authenticate

  # GET /game_robots
  # GET /game_robots.xml
  def index
    @game_robots = GameRobot.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @game_robots }
    end
  end

  # GET /game_robots/1
  # GET /game_robots/1.xml
  def show
    @game_robot = GameRobot.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @game_robot }
    end
  end

  # GET /game_robots/new
  # GET /game_robots/new.xml
  def new
    @game_robot = GameRobot.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @game_robot }
    end
  end

  # GET /game_robots/1/edit
  def edit
    @game_robot = GameRobot.find(params[:id])
  end

  # POST /game_robots
  # POST /game_robots.xml
  def create
    @game_robot = GameRobot.new(params[:game_robot])

   if @game_robot.save


      render :partial=>"save_result"

      else
        flash[:message] = "There was an error saving the game robot."
      end
  end

  # PUT /game_robots/1
  # PUT /game_robots/1.xml
  def update
    @game_robot = GameRobot.find(params[:id])

    respond_to do |format|
      if @game_robot.update_attributes(params[:game_robot])
        flash[:notice] = 'GameRobot was successfully updated.'
        format.html { redirect_to(@game_robot) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @game_robot.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /game_robots/1
  # DELETE /game_robots/1.xml
  def destroy
    @game_robot = GameRobot.find(params[:id])
    @game_robot.destroy

    respond_to do |format|
      format.html { redirect_to(game_robots_url) }
      format.xml  { head :ok }
    end
  end

 

end
