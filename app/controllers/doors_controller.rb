class DoorsController < ApplicationController

  before_filter :authenticate

#  TODO clean up this controller so that the actions are not accessible through routes
  # GET /doors
  # GET /doors.xml
  def index
    @section = Section.find(params[:section_id])
    @room = Room.find(params[:room_id])
    @doors = Door.find(:all, :conditions => "parent_room_id = #{params[:room_id]} OR child_room_id = #{params[:room_id]}")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @doors }
    end
  end

  # GET /doors/1
  # GET /doors/1.xml
  def show
    @section = Section.find(params[:section_id])
    @room = Room.find(params[:room_id])
    @door = Door.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @door }
    end
  end

  # GET /doors/new
  # GET /doors/new.xml
  def new
    @section = Section.find(params[:section_id])
    @room = Room.find(params[:room_id])
    @door = Door.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @door }
    end
  end

  # GET /doors/1/edit
  def edit
    @door = Door.find(params[:id])
  end

  # POST /doors
  # POST /doors.xml
  def create
    @section = Section.find(params[:section_id])
    @room = Room.find(params[:room_id])
    @door = Door.new(params[:door])

    respond_to do |format|
      if @door.save
#        flash[:notice] = 'Door was successfully created.'
        format.html { redirect_to(section_rooms_path(@section)) }
        format.xml  { render :xml => @door, :status => :created, :location => @door }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @door.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /doors/1
  # PUT /doors/1.xml
  def update
    @door = Door.find(params[:id])

    respond_to do |format|
      if @door.update_attributes(params[:door])
        flash[:notice] = 'Door was successfully updated.'
        format.html { redirect_to(@door) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @door.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /doors/1
  # DELETE /doors/1.xml
  def destroy
    @section = Section.find(params[:section_id])
    @door = Door.find(params[:id])
    @door.destroy

    respond_to do |format|
      format.html { redirect_to(section_rooms_path(@section)) }
      format.xml  { head :ok }
    end
  end

  
end
