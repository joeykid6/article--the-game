require 'RMagick'
class SectionsController < ApplicationController
  include Magick

  before_filter :authenticate, :except => [:article_map, :worldmap]
  before_filter :game_check_then_authenticate, :only => [:article_map, :worldmap]

  # GET /sections
  # GET /sections.xml
  def index
    @sections = Section.all(:order => :position)

    respond_to do |format|
      format.html # index.html.erb
#      format.xml  { render :xml => @sections }
    end
  end

  # GET /sections/1
  # GET /sections/1.xml
  def show
    @section = Section.find(params[:id])
    @starting_room = @section.rooms.find_by_starting_room(1)

    respond_to do |format|
      if current_game
        format.html { redirect_to section_room_path(@section, @starting_room) }
      else
        format.html # show.html.erb
  #      format.xml  { render :xml => @section }
      end
    end
  end

  # GET /sections/new
  # GET /sections/new.xml
  def new
    @section = Section.new
    @new_position = Section.all.empty? ? 1 : (Section.last(:order => :position).position.to_i + 1)

    respond_to do |format|
      format.html # new.html.erb
#      format.xml  { render :xml => @section }
    end
  end

  # GET /sections/1/edit
  def edit
    @section = Section.find(params[:id])
  end

  # POST /sections
  # POST /sections.xml
  def create
    @section = Section.new(params[:section])

    respond_to do |format|
      if @section.save
        flash[:notice] = 'Section was successfully created.'
        format.html { redirect_to sections_path }
#        format.xml  { render :xml => @section, :status => :created, :location => @section }
      else
        format.html { render :action => "new" }
#        format.xml  { render :xml => @section.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sections/1
  # PUT /sections/1.xml
  def update
    @section = Section.find(params[:id])

    respond_to do |format|
      if @section.update_attributes(params[:section])
        flash[:notice] = 'Section was successfully updated.'
        format.html { redirect_to sections_path }
#        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
#        format.xml  { render :xml => @section.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sections/1
  # DELETE /sections/1.xml
  def destroy
    @section = Section.find(params[:id])
    @section.destroy

    respond_to do |format|
      format.html { redirect_to(sections_url) }
#      format.xml  { head :ok }
    end
  end

  def sort_sections
    if request.xhr?
      @sections = Section.all
      @sections.each do |section|
        section.position = params["section_list"].index(section.id.to_s) + 1
        section.save
      end
    end
    render :nothing => true
  end

  #  Generates a map image of all sections in the current game, highlighting the current section,
  #  displaying the other visited sections, and obscuring those sections that haven't been
  #  visited yet.
  #  The default numbers work for a 2 column display of sections.
  def worldmap
    @game = current_game
    @sections = Section.all(:order => :position)
    @section = Section.find(params[:section_id])

    image_width = @sections.size > 4 ? 560 : 580 #remember to change this in article_map action also
    even_sections_count = @sections.size.odd?  ?  (@sections.size + 1)  :  @sections.size
    image_height = (@sections.size <= 2)  ?  image_width  :  image_width * even_sections_count / 4
    border_size = 1
    border_color = '#000000'
    section_title_font = "AdobeHeitiStd-Regular" #TODO Copy font to server
    section_title_pointsize = 18
    room_size = 40
    room_interior_padding = 5
    room_spacing = 2
    title_y_offset = 25

#    initialize the image
    canvas = Magick::Image.new(image_width, image_height, Magick::HatchFill.new('white','lightcyan2',10))
    canvas.border!( border_size, border_size, border_color )

#    draw horizontal dividing lines on the image
    1.upto(even_sections_count/2 - 1) do |i|
      dividing_line = Magick::Draw.new
      dividing_line.stroke( border_color )
      dividing_line.stroke_width( border_size )
      dividing_line.line( 0, ( i.to_i * image_height / (even_sections_count/2) ), image_width, ( i.to_i * image_height / (even_sections_count/2) ) )
      dividing_line.draw(canvas)
    end if even_sections_count > 2

    if @sections.size > 1
#      draw the vertical center line on the image
      center_line = Magick::Draw.new
      center_line.stroke( border_color )
      center_line.stroke_width( border_size )
      center_line.line((image_width/2).to_i, 0, (image_width/2).to_i, image_height)

      center_line.draw(canvas)
 
#      draw the section maps on the image
      @sections.each do |section|

#        set section color, opacity, and possibly other attributes
        if section.id == @section.id
          box_color = '#000000'
          box_opacity = "60%"
          section_status_text = "Current Section"
          section_status_pointsize = 36
          section_status_opacity = "50%"
          section_status_color = "#dd0000"

        elsif @game.visible_sections.exists?(section)
          box_color = '#000000'
          box_opacity = "60%"
          section_status_text = " "
          section_status_pointsize = 12
          section_status_opacity = "100%" #not currently used
          section_status_color = "#000000" #not currently used

        else
          box_color = '#444444'
          box_opacity = "8%"
          section_status_text = "?"
          section_status_pointsize = 72
          section_status_opacity = "100%" #not currently used
          section_status_color = "#000000" #not currently used

        end

#        set x and y start positions for section draws
        x_start_position = section.position.to_i.odd? ? 0 : ( image_width / 2 ).to_i
        y_start_position = section.position.to_i.odd? ?
          ( ( section.position.to_i + 1 ) / 2 - 1 ) * image_height / ( even_sections_count/2 ) :
          ( section.position.to_i/2 - 1 ) * image_height / ( even_sections_count/2 )
#        TODO test layout with two sections only; modify y_start_position accordingly on line below
#        y_start_position += image_height/4 if even_sections_count == 2

#        Draw a title for each section
        section_title = Magick::Draw.new
        section_title_text = @game.visible_sections.exists?(section) ? section.name : " "
        section_title.pointsize(section_title_pointsize)
        section_title.font_family(section_title_font)
        section_title.text_align(CenterAlign)
        section_title.text((x_start_position + image_width/4 + 1).to_i, (y_start_position + title_y_offset).to_i, section_title_text)

        section_title.draw(canvas)

#        find all rooms for this section so we can draw them
        rooms = section.rooms

#        figure out x_offset and y_offset to center the section drawing inside its area
        max_column = rooms.maximum("col")
        min_column = rooms.minimum("col")

        max_row = rooms.maximum("row")
        min_row = rooms.minimum("row")

        vertical_center_of_section = image_width/4.to_i
        horizontal_center_of_section = image_height/even_sections_count.to_i

        number_of_columns = (max_column - min_column + 1).to_i
        number_of_rows = (max_row - min_row + 1).to_i

        median_column = number_of_columns.odd? ? (min_column + 1 + (number_of_columns - 1)/2).to_i : (min_column + number_of_columns/2).to_i
        median_row = number_of_rows.odd? ? (min_row + 1 + (number_of_rows - 1)/2).to_i : (min_row + number_of_rows/2).to_i

        x_offset = number_of_columns.odd? ? 
          vertical_center_of_section - median_column * room_size + room_spacing + (room_size/2).to_i :
          vertical_center_of_section - (median_column * room_size - room_spacing)

        y_offset = number_of_rows.odd? ?
          horizontal_center_of_section - median_row * room_size + room_spacing + (room_size/2).to_i :
          horizontal_center_of_section - (median_row * room_size - room_spacing)

#        Create the new draw object for the rooms in this section
        room_box = Magick::Draw.new

#        draw each of the rooms
        rooms.each do |room|
          
          room_x1 = (x_start_position + room_size * room.col.to_i) + x_offset
          room_y1 = (y_start_position + room_size * room.row.to_i) + y_offset
          room_x2 = room_x1 + room_size - room_spacing
          room_y2 = room_y1 + room_size - room_spacing


          room_box.stroke(box_color)
          room_box.stroke_width(border_size)
          room_box.opacity(box_opacity)

#          Lines to connect inner and outer boxes
          room_box.line(room_x1,
            room_y1,
            room_x1 + room_interior_padding,
            room_y1 + room_interior_padding)
          room_box.line(room_x2,
            room_y1,
            room_x2 - room_interior_padding,
            room_y1 + room_interior_padding)
          room_box.line(room_x1,
            room_y2,
            room_x1 + room_interior_padding,
            room_y2 - room_interior_padding)
          room_box.line(room_x2,
            room_y2,
            room_x2 - room_interior_padding,
            room_y2 - room_interior_padding)

          room_box.fill(box_color)
          room_box.fill_opacity(box_opacity)
          room_box.rectangle(room_x1, room_y1, room_x2, room_y2)
          room_box.rectangle(room_x1 + room_interior_padding,
            room_y1 + room_interior_padding,
            room_x2 - room_interior_padding,
            room_y2 - room_interior_padding)


        end

        room_box.draw(canvas) #end of section rooms draw

#        Draw a status message for each section
        section_status = Magick::Draw.new
        section_status.pointsize(section_status_pointsize)
        section_status.font_family(section_title_font)
        section_status.text_align(CenterAlign)
        section_status.stroke(section_status_color) if section.id == @section.id
        section_status.fill(section_status_color) if section.id == @section.id
        section_status.opacity(section_status_opacity) if section.id == @section.id
#        section_status.kerning(6)
        section_status.text((x_start_position + image_width/4 + 1).to_i,
          ( y_start_position + ( image_height / even_sections_count ) + (section_status_pointsize / 2.4) ).to_i,
          section_status_text)

        section_status.draw(canvas)

      end
      
    else
      section_alert = Magick::Draw.new
      section_alert.annotate(canvas, 0, 0, 0, 0, "There is only one section in this article.\nYou are in it.") {
        self.font_family = 'Arial'
        self.fill = '#000000'
        self.stroke = '#000000'
        self.pointsize = 28
        self.gravity = CenterGravity
      }
    end

    canvas.format = "png"
    
    send_data canvas.to_blob,
        :filename => 'article_map.png',
        :type => 'img/png',
        :disposition => 'inline'

  end

#  This action is necessary for lightview to have something to render with the worldmap inside it.
#  Otherwise, there's no way to create a view with the image map links.
  def article_map
    @game = current_game
    @sections = Section.all(:order => :position)
    @section = Section.find(params[:section_id])

    @image_width = @sections.size > 4 ? 560 : 580 #remember to change this in worldmap action also
    @even_sections_count = @sections.size.odd?  ?  (@sections.size + 1)  :  @sections.size
    @image_height = (@sections.size <= 2)  ?  @image_width  :  @image_width * @even_sections_count / 2

    render :layout => false

  end


end
