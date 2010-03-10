class DialogueLinesController < ApplicationController

  before_filter :authenticate
  rescue_from ::NoMethodError, :with=>:no_method_recover
  # GET /dialogue_lines
  # GET /dialogue_lines.xml
  uses_tiny_mce :options => {
                              :theme=>'advanced',
                              :theme_advanced_disable=>'underline,strikethrough,justifyleft,justifycenter,justifyright,justifyfull,bullist,numlist,outdent,indent,image,cleanup,help,hr,removeformat,formatselect,fontselect,fontsizeselect,styleselect,sub,sup,forecolor,backcolor,forecolorpicker,backcolorpicker,charmap,visualaid,anchor,newdocument,blockquote,separator',

                              :theme_advanced_buttons1 => 'bold,italic,cut,copy,paste,link,unlink,code',
                              :theme_advanced_buttons2 => "",
                              :theme_advanced_buttons3 => "",


                              :force_br_newlines=>'true',
                              :forced_root_block=>''
                            }


 




  def index
    @section = Section.find(params[:section_id])
    @room = Room.find(params[:room_id])

    
    

    @dialogue_lines = DialogueLine.find(:all,
      :conditions=> ["room_id = ? and parent_id is NULL",params[:room_id]] )

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dialogue_lines }
    end
  end

  # GET /dialogue_lines/1
  # GET /dialogue_lines/1.xml
  def show
     @section=Section.find(params[:section_id])
     @room = Room.find(params[:room_id])
     @dialogue_line = DialogueLine.find(params[:id])
     @media_objects = MediaObject.find(:all, 
       :conditions => ['dialogue_line_id = ?', @dialogue_line.id],
       :joins => :dialogue_lines)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @dialogue_line }
    end
  end

  # GET /dialogue_lines/new
  # GET /dialogue_lines/new.xml
  def new
    @section=Section.find(params[:section_id])
    @room = Room.find(params[:room_id])
    
    #@media_objects=@room.media_objects.find(:all)

    @dialogue_line = DialogueLine.new
    @all_generators = LineGenerator.find(:all,
                                        :select=>"line_generator_type",
                                        :group=>"line_generator_type")
  

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @dialogue_line }
    end
  end

  # GET /dialogue_lines/1/edit
  def edit
    @section=Section.find(params[:section_id])
    @room = Room.find(params[:room_id])
    @dialogue_line = DialogueLine.find(params[:id])
    @all_generators = LineGenerator.find(:all,
                                        :select=>"line_generator_type",
                                        :group=>"line_generator_type")


   
    @existing_generator = @dialogue_line.line_generator_type.constantize.find(:all, :order=>'name')

    @media_objects=MediaObject.find(:all, :conditions=>['dialogue_line_id = ?', @dialogue_line.id], :joins=>:dialogue_lines)
    
    @doors=Door.find(:all, :conditions=>['dialogue_line_id = ?', @dialogue_line.id], :joins=>:dialogue_lines)


    #@guides = Guide.find(:all, :conditions=>["id IN (?)", @root_lines_visible.map(&:line_generator_id)])

   
   
    @triggered_ids=DialogueLine.find(:all,
      :select=>"invisible_dialogue_line_id",
      :from=>"visible_dialogue_lines_invisible_dialogue_lines",
      :conditions=>["visible_dialogue_line_id = ?",@dialogue_line.id])

    @triggered_dialogue_lines = DialogueLine.find(:all,
      :conditions=>["id IN (?)",@triggered_ids.map(&:invisible_dialogue_line_id)]
    )



   

    #@triggered_dialogue_lines=DialogueLine.find(:all, :conditions=>['id IN (?)',@triggered_ids.id],
      #:joins=>:invisible_dialogue_lines)

    #    All the doors in the room, found through the has_many :through helpers
    
    
  end

  # POST /dialogue_lines
  # POST /dialogue_lines.xml
  def create

    @section=Section.find(params[:section_id])
    @room = Room.find(params[:room_id])
    @dialogue_line = DialogueLine.new(params[:dialogue_line])

    respond_to do |format|
      if @dialogue_line.save
        flash[:message] = 'DialogueLine was successfully created.'
        
#        The string conditional below must match the submit text in new.html.erb
        format.html { redirect_to( params[:commit] == "Save line and return to list" ?
              section_room_dialogue_lines_path(@section, @room) : 
              new_section_room_dialogue_line_path(@section, @room)) }
        
        format.xml  { render :xml => @dialogue_line, :status => :created, :location => @dialogue_line }
      else
        #format.html { render :action => "new" }
        #format.xml  { render :xml => @dialogue_line.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /dialogue_lines/1
  # PUT /dialogue_lines/1.xml
  def update

    

    @section=Section.find(params[:section_id])
    @room = Room.find(params[:room_id])
    @dialogue_line = DialogueLine.find(params[:id])
    
    
      if @dialogue_line.update_attributes(params[:dialogue_line])
        
        flash[:message] = "Dialogue line successfully updated."
        redirect_to(section_room_dialogue_lines_path(@section, @room))

      else
        flash[:notice] = "There was an error saving the dialogue line."

      end

  end

  # DELETE /dialogue_lines/1
  # DELETE /dialogue_lines/1.xml
  def destroy
    @dialogue_line = DialogueLine.find(params[:id])
    @dialogue_line.destroy

    respond_to do |format|
      format.html { redirect_to(section_room_dialogue_lines_path) }
      format.xml  { head :ok }
    end
  end

  def restructure

    @section = params[:section_id]
    @room = params[:room_id]
    _parent = DialogueLine.find(params[:dialogue_line_id].gsub('dialogue_line_',''))
    _child = DialogueLine.find(params[:subcategory_id].gsub('dialogue_line_',''))
    _child.move_to_child_of(_parent)

    
    



    @dialogue_lines = DialogueLine.find(:all,
     :conditions=> ["room_id = ? and parent_id is NULL",params[:room_id]] )
    
    if request.xhr?
        render :update do |page|
      page.redirect_to(:action=>'index', :room_id=>@room, :section_id=>@section)
    end
    end
    
    #render :partial => 'dialogue_lines_tree',
           #:locals=>{:dialogue_lines=>@dialogue_lines}

  rescue ActiveRecord::ActiveRecordError
    logger.error("Attempt to put a parent into its child")
    flash[:notice]="You can't put a parent into its child!"
    render :update do |page|
      page.redirect_to(:action=>'index', :room_id=>@room, :section_id=>@section)
    end  
  end

  def make_root
    @section = params[:section_id]
    @room = params[:room_id]

    DialogueLine.find(params[:dialogue_line_id]).move_to_root

    
    redirect_to(section_room_dialogue_lines_path(@section,@room))
    
  end

  def copy_line
    @section = params[:section_id]
    @room = params[:room_id]
    
    copy_line = DialogueLine.find(params[:dialogue_line_id])


    my_line = DialogueLine.new
    my_line.content = copy_line.content
    my_line.line_generator_id = copy_line.line_generator_id
    my_line.line_generator_type = copy_line.line_generator_type
    my_line.room_id = copy_line.room_id
    my_line.visible = copy_line.visible
    my_line.save

    redirect_to(section_room_dialogue_lines_path(@section,@room))
    
  end


  def find_generators
    @generators = params[:value].constantize.find(:all, :order=>'name')
  end


  def select_media_objects

    @section=Section.find(params[:section_id])
    @room = Room.find(params[:room_id])
    @dialogue_line = DialogueLine.find(params[:id])

  end

  def select_doors

    @section=Section.find(params[:section_id])
    @room = Room.find(params[:room_id])
    @dialogue_line = DialogueLine.find(params[:id])

  end

  def select_invisible_dialogue_lines

    @section=Section.find(params[:section_id])
    @room = Room.find(params[:room_id])
    @dialogue_line = DialogueLine.find(params[:id])

  end


private

  def no_method_recover
    render :partial => "problem"
  end


end


