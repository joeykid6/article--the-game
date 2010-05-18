# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

def lightview_link(line_content)
        if line_content.match(/href=/ix)
            line_content.gsub(/href=/ix,"class='lightview' title=':: ::fullscreen:true' rel='iframe' href=")
          else
            line_content
          end
end

# only sends out default sized thumbnail routes right now  TODO refactor to include size
def fixed_paperclip_route(object)
  "/kairosgame#{object.thumbnail.url}"
end

end