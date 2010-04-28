pdf.text "Bibliography from all the rooms you have visited", :size => 16, :style => :bold, :align => :center
pdf.move_down(20)

@visible_speakers.each do |visible_speaker|
  pdf.text visible_speaker.source_name,
    :indent_paragraphs => -12,
    :inline_format => true
  pdf.move_down(10)
end
