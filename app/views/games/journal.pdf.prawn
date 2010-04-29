pdf.text "Bibliography", :size => 16, :style => :bold, :align => :center
pdf.text "<em>Game played by #{@game.short_name} (#{number_to_percentage(@progress, :precision => 0)} complete)</em>",
  :size => 11,
  :align => :center,
  :inline_format => true
pdf.move_down(20)

@visible_speakers.each do |visible_speaker|
  pdf.text visible_speaker.source_name,
    :indent_paragraphs => -12,
    :inline_format => true
  pdf.move_down(10)
end
