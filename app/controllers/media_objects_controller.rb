class MediaObjectsController < ApplicationController

  before_filter :authenticate

  # GET /media_objects
  # GET /media_objects.xml
  def index

    @media_objects = MediaObject.all

    

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @media_objects }
    end
  end

  # GET /media_objects/1
  # GET /media_objects/1.xml
  def show

    

    @media_object = MediaObject.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @media_object }
    end
  end

  # GET /media_objects/new
  # GET /media_objects/new.xml
  def new
    #@section = Section.find(params[:section_id])
    #@room = Room.find(params[:room_id])
    #@dialogue_line=DialogueLine.find(params[:dialogue_line_id])

    
    @media_object=MediaObject.new
    #@media_object = @dialogue_line.media_objects.build
    #@room=Room.find(params[:room_id])
    #@section=Section.find(params[:section_id])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @media_object }
    end
  end

  # GET /media_objects/1/edit
  def edit
    #@section = Section.find(params[:section_id])
    #@room = Room.find(params[:room_id])
    #@dialogue_line=DialogueLine.find(params[:dialogue_line_id])
    @media_object = MediaObject.find(params[:id])
  end

  # POST /media_objects
  # POST /media_objects.xml
  def create

    #@section = Section.find(params[:section_id])
   # @room = Room.find(params[:room_id])
    #@dialogue_line=DialogueLine.find(params[:dialogue_line_id])
    @media_object = MediaObject.new(params[:media_object])

    #@media_object = @dialogue_line.media_objects.create params[:media_object]
    #@room=Room.find(params[:room_id])
    #@section=Section.find(params[:section_id])

    
      respond_to do |format|
        if @media_object.save

        flash[:notice] = 'Media object was successfully created.'
        format.html { redirect_to(media_objects_path) }
        #render :partial=>"save_result"
      else
        flash[:message] = "There was an error saving the media object.  Did you browse for a picture to upload?"
        render :partial =>"problem"
      end
      end
    end

  # PUT /media_objects/1
  # PUT /media_objects/1.xml
  def update

    #@section = Section.find(params[:section_id])
    #@room = Room.find(params[:room_id])
    #@dialogue_line=DialogueLine.find(params[:dialogue_line_id])
    @media_object = MediaObject.find(params[:id])

   
      respond_to do |format|
      if @media_object.update_attributes(params[:media_object])
        flash[:notice] = 'Media object was successfully updated.'
        format.html { redirect_to(media_objects_path) }
        format.xml  { head :ok }
      else
        flash[:message] = "There was an error saving the media object.  Did you browse for a picture to upload?"
        render :partial =>"problem"
      end
    end
  end

  # DELETE /media_objects/1
  # DELETE /media_objects/1.xml
  def destroy
  
    

    @media_object = MediaObject.find(params[:id])
    @media_object.destroy

    respond_to do |format|
      format.html { redirect_to(media_objects_path) }
      format.xml  { head :ok }
    end
  end

  def update_media

    @section = Section.find(params[:section_id])
    @room = Room.find(params[:room_id])
    @dialogue_line=DialogueLine.find(params[:dialogue_line_id])

    @media_objects=MediaObject.find(:all, :conditions=>['dialogue_line_id = ?', @dialogue_line.id], :joins=>:dialogue_lines)

    render :partial=>"update_media",:locals =>{:media_objects=>@media_objects}
end

end
