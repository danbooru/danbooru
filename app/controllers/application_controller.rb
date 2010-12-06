class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_current_user
  after_filter :reset_current_user
  before_filter :initialize_cookies
  before_filter :set_title
  layout "default"
  
  rescue_from User::PrivilegeError, :with => :access_denied

protected
  def access_denied
    previous_url = params[:url] || request.request_uri

    respond_to do |fmt|
      fmt.html do 
        if request.get?
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
      CurrentUser.user = User.find_by_id(session[:user_id])
      CurrentUser.ip_addr = request.remote_ip
    end
    
    if CurrentUser.user
      if CurrentUser.user.is_banned? && CurrentUser.user.ban && CurrentUser.user.ban.expires_at < Time.now
        CurrentUser.user.unban!
      end
    else
      CurrentUser.user = AnonymousUser.new
    end
    
    Time.zone = CurrentUser.user.time_zone
  end
  
  def reset_current_user
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
  end
  
  %w(member banned privileged contributor janitor moderator admin).each do |level|
    define_method("#{level}_only") do
      if CurrentUser.user.__send__("is_#{level}?")
        true
      else
        access_denied()
      end
    end
  end

  def initialize_cookies
    if CurrentUser.user.is_anonymous?
      cookies["blacklisted_tags"] = ""
    else
      cookies["blacklisted_tags"] = CurrentUser.user.blacklisted_tags
    end
  end
  
  def set_title
    @page_title = Danbooru.config.app_name + "/#{params[:controller]}"
  end
end
