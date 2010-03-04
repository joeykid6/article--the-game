# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  USER_NAME = "admin"
  PASSWORD = "admin" #TODO change before going into production

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def close_lightview
    if request.xhr?
        render :update do |page|
            page << "parent.Lightview.hide();"
          end
    end
  end

  
  private

  def game_check_then_authenticate
    authenticate unless current_game
  end

  def authenticate
    authenticate_or_request_with_http_basic do |user_name, password|
      user_name == USER_NAME && password == PASSWORD
      
      if user_name == USER_NAME && password == PASSWORD
        session[:authenticated] = "yes"
      end
    end
  end


  def current_game
    @_current_game ||= session[:current_game_id] &&
      Game.find(session[:current_game_id])
  end


end
