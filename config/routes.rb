ActionController::Routing::Routes.draw do |map|

  map.connect '/sections/:section_id/rooms/:room_id/dialogue_line/:id/', :controller=>'media_objects', :action=>'update_media'

  map.resources :game_robots

  map.resources :guides

  map.resources :speakers

  map.resources :media_objects

  map.minimap '/sections/:section_id/rooms/:id/minimap', :controller => 'rooms', :action => 'minimap'
  map.section_map '/sections/:section_id/rooms/:id/section_map', :controller => 'rooms', :action => 'section_map'
  map.worldmap '/sections/:section_id/worldmap', :controller => 'sections', :action => 'worldmap'
  map.article_map '/sections/:section_id/article_map', :controller => 'sections', :action => 'article_map'
  map.journal '/games/:game_id/journal.:format', :controller => 'games', :action => 'journal'
  
  map.resources :games

  map.resources :sections do |section|
    section.resources :rooms do |room|
      room.resources :doors
      room.resources :dialogue_lines
    end
  end

  
  map.root :controller => 'games'
 
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
