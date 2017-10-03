class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :pagination
  before_filter :reset_current_user
  before_filter :set_current_user
  after_filter :reset_current_user
  before_filter :set_title
  before_filter :normalize_search
  before_filter :set_started_at_session
  before_filter :api_check
  before_filter :set_safe_mode
  # before_filter :secure_cookies_check
  layout "default"
  force_ssl :if => :ssl_login?
  helper_method :show_moderation_notice?

  rescue_from Exception, :with => :rescue_exception
  rescue_from User::PrivilegeError, :with => :access_denied
  rescue_from SessionLoader::AuthenticationFailure, :with => :authentication_failed
  rescue_from Danbooru::Paginator::PaginationError, :with => :render_pagination_limit

  protected

  def show_moderation_notice?
    CurrentUser.can_approve_posts? && (cookies[:moderated].blank? || Time.at(cookies[:moderated].to_i) < 20.hours.ago)
  end

  def ssl_login?
    cookies[:ssl_login].present?
  end

  def enable_cors
    response.headers["Access-Control-Allow-Origin"] = "*"
  end

  def require_reportbooru_key
    unless params[:key] == Danbooru.config.reportbooru_key
      render(text: "forbidden", status: 403)
      return false
    end
  end
  
  def api_check
    if !CurrentUser.is_anonymous? && !request.get? && !request.head?
      if CurrentUser.user.token_bucket.nil?
        TokenBucket.create_default(CurrentUser.user)
        CurrentUser.user.reload
      end

      throttled = CurrentUser.user.token_bucket.throttled?
      headers["X-Api-Limit"] = CurrentUser.user.token_bucket.token_count.to_s

      if throttled
        respond_to do |format|
          format.json do
            render json: {success: false, reason: "too many requests"}.to_json, status: 429
          end

          format.xml do
            render xml: {success: false, reason: "too many requests"}.to_xml(:root => "response"), status: 429
          end

          format.html do
            render :template => "static/too_many_requests", :status => 429
          end
        end

        return false
      end
    end

    return true
  end

  def rescue_exception(exception)
    @exception = exception

    if exception.is_a?(::ActiveRecord::StatementInvalid) && exception.to_s =~ /statement timeout/
      if Rails.env.production?
        NewRelic::Agent.notice_error(exception, :uri => request.original_url, :referer => request.referer, :request_params => params, :custom_params => {:user_id => CurrentUser.user.id, :user_ip_addr => CurrentUser.ip_addr})
      end

      @error_message = "The database timed out running your query."
      render :template => "static/error", :status => 500
    elsif exception.is_a?(::ActiveRecord::RecordNotFound)
      @error_message = "That record was not found"
      render :template => "static/error", :status => 404
    elsif exception.is_a?(NotImplementedError)
      flash[:notice] = "This feature isn't available: #{@exception.message}"
      respond_to do |fmt|
        fmt.html { redirect_to :back }
        fmt.json { render template: "static/error", status: 501 }
        fmt.xml  { render template: "static/error", status: 501 }
      end
    else
      render :template => "static/error", :status => 500
    end
  end

  def render_pagination_limit
    @error_message = "You can only view up to #{Danbooru.config.max_numbered_pages} pages. Please narrow your search terms."
    render :template => "static/error", :status => 410
  end

  def authentication_failed
    respond_to do |fmt|
      fmt.html do
        render :text => "authentication failed", :status => 401
      end

      fmt.xml do
        render :xml => {:sucess => false, :reason => "authentication failed"}.to_xml(:root => "response"), :status => 401
      end

      fmt.json do
        render :json => {:success => false, :reason => "authentication failed"}.to_json, :status => 401
      end
    end
  end

  def access_denied(exception = nil)
    previous_url = params[:url] || request.fullpath

    respond_to do |fmt|
      fmt.html do
        if CurrentUser.is_anonymous?
          if request.get?
            redirect_to new_session_path(:url => previous_url), :notice => "Access denied"
          else
            redirect_to new_session_path, :notice => "Access denied"
          end
        else
          render :template => "static/access_denied", :status => 403
        end
      end
      fmt.xml do
        render :xml => {:success => false, :reason => "access denied"}.to_xml(:root => "response"), :status => 403
      end
      fmt.json do
        render :json => {:success => false, :reason => "access denied"}.to_json, :status => 403
      end
      fmt.js do
        render :nothing => true, :status => 403
      end
    end
  end

  def set_current_user
    session_loader = SessionLoader.new(session, cookies, request, params)
    session_loader.load
  end

  def reset_current_user
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
    CurrentUser.mobile_mode = false
  end

  def set_started_at_session
    if session[:started_at].blank?
      session[:started_at] = Time.now
    end
  end

  User::Roles.each do |role|
    define_method("#{role}_only") do
      if !CurrentUser.user.is_banned_or_ip_banned? && CurrentUser.user.__send__("is_#{role}?")
        true
      else
        access_denied()
        false
      end
    end
  end

  def set_title
    @page_title = Danbooru.config.app_name + "/#{params[:controller]}"
  end

  def normalize_search
    if request.get?
      if params[:search].blank?
        params[:search] = {}
      end

      if params[:search].is_a?(Hash)
        changed = params[:search].reject! {|k,v| v.blank?}
        unless changed.nil?
          redirect_to url_for(params)
        end
      end
    end
  end

  def set_safe_mode
    CurrentUser.set_safe_mode(request)
  end

  def secure_cookies_check
    if request.ssl?
      Rails.application.config.session_store :cookie_store, :key => '_danbooru_session', :secure => true
    else
      Rails.application.config.session_store :cookie_store, :key => '_danbooru_session', :secure => false
    end
  end
end
