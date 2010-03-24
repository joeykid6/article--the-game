# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

def lightview_link(line_content)
        if line_content.match(/href=/ix)
            line_content.gsub(/href=/ix,"class='lightview' title=':: ::fullscreen:true' rel='iframe' href=")
          else
            line_content
          end
end



end