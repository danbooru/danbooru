class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_current_user
  before_filter :initialize_cookies
  layout "default"

protected
  def access_denied
    previous_url = params[:url] || request.request_uri

    respond_to do |fmt|
      fmt.html do 
        if request.get? && Rails.env.test?
          redirect_to new_session_path(:url => previous_url), :notice => "Access denied"
        else
          redirect_to new_session_path, :notice => "Access denied"
        end
      end
      fmt.xml do
        render :xml => {:success => false, :reason => "access denied"}.to_xml(:root => "response"), :status => 403
      end
      fmt.json do
        render :json => {:success => false, :reason => "access denied"}.to_json, :status => 403
      end
    end
  end

  def set_current_user
    if session[:user_id]
      @current_user = User.find_by_id(session[:user_id])
    end
    
    if @current_user
      if @current_user.is_banned? && @current_user.ban && @current_user.ban.expires_at < Time.now
        @current_user.update_attribute(:is_banned, false)
        Ban.destroy_all("user_id = #{@current_user.id}")
      end
    else
      @current_user = AnonymousUser.new
    end
    
    Time.zone = @current_user.time_zone
  end
  
  %w(member banned privileged contributor janitor moderator admin).each do |level|
    define_method("#{level}_only") do
      if @current_user.__send__("is_#{level}?")
        true
      else
        access_denied()
      end
    end
  end

  def initialize_cookies
    if @current_user.is_anonymous?
      cookies["blacklisted_tags"] = ""
    else
      cookies["blacklisted_tags"] = @current_user.blacklisted_tags
    end
  end
end
