class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_current_user
  before_filter :initialize_cookies

protected
  def access_denied
    previous_url = params[:url] || request.request_uri

    respond_to do |fmt|
      fmt.html do 
        if request.get? && Rails.environment != "test"
          redirect_to new_sessions_path(:url => previous_url), :notice => "Access denied"
        else
          redirect_to new_sessions_path, :notice => "Access denied"
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
    if @current_user == nil && session[:user_id]
      @current_user = User.find_by_id(session[:user_id])
    end

    if @current_user == nil && params[:user]
      @current_user = User.authenticate(params[:user][:name], params[:user][:password])
    end
    
    if @current_user == nil && params[:api]
      @current_user = User.authenticate(params[:api][:key], params[:api][:hash])
    end

    if @current_user
      if @current_user.is_banned? && @current_user.ban && @current_user.ban.expires_at < Time.now
        @current_user.update_attribute(:is_banned, false)
        Ban.destroy_all("user_id = #{@current_user.id}")
      end

      session[:user_id] = @current_user.id
    else
      @current_user = AnonymousUser.new
    end
  end
  
  %w(banned privileged contributor janitor moderator admin).each do |level|
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
