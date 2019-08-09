class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :pagination
  before_action :reset_current_user
  before_action :set_current_user
  after_action :reset_current_user
  before_action :set_title
  before_action :normalize_search
  before_action :set_started_at_session
  before_action :api_check
  before_action :set_safe_mode
  before_action :set_variant
  before_action :track_only_param
  layout "default"
  helper_method :show_moderation_notice?
  before_action :enable_cors

  rescue_from Exception, :with => :rescue_exception
  rescue_from User::PrivilegeError, :with => :access_denied
  rescue_from SessionLoader::AuthenticationFailure, :with => :authentication_failed
  rescue_from ActionController::UnpermittedParameters, :with => :access_denied

  # This is raised on requests to `/blah.js`. Rails has already rendered StaticController#not_found
  # here, so calling `rescue_exception` would cause a double render error.
  rescue_from ActionController::InvalidCrossOriginRequest, with: -> {}

  protected

  def show_moderation_notice?
    CurrentUser.can_approve_posts? && (cookies[:moderated].blank? || Time.at(cookies[:moderated].to_i) < 20.hours.ago)
  end

  def enable_cors
    response.headers["Access-Control-Allow-Origin"] = "*"
  end

  def track_only_param
    if params[:only]
      RequestStore[:only_param] = params[:only].split(/,/)
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

    case exception
    when ActiveRecord::QueryCanceled
      if Rails.env.production?
        NewRelic::Agent.notice_error(exception, :uri => request.original_url, :referer => request.referer, :request_params => params, :custom_params => {:user_id => CurrentUser.user.id, :user_ip_addr => CurrentUser.ip_addr})
      end

      render_error_page(500, "The database timed out running your query.")
    when ActiveRecord::RecordNotFound
      render_error_page(404, "That record was not found")
    when ActionController::UnknownFormat
      @error_message = "#{request.format.to_s} is not a supported format for this page."
      render "static/error.html", status: 406
    when Danbooru::Paginator::PaginationError
      render_error_page(410, @exception.message)
    when NotImplementedError
      render_error_page(501, "This feature isn't available: #{@exception.message}")
    when PG::ConnectionBad
      render_error_page(503, "The database is unavailable. Try again later.")
    else
      render_error_page(500, @exception.message)
    end
  end

  def render_error_page(status, message)
    @error_message = message

    if request.format.symbol.in?(%i[html json xml js atom])
      render template: "static/error", status: status
    else
      render template: "static/error.html", status: status
    end
  end

  def authentication_failed
    respond_to do |fmt|
      fmt.html do
        render :plain => "authentication failed", :status => 401
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
        render js: "", :status => 403
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
    CurrentUser.root_url = root_url.chomp("/")
  end

  def set_started_at_session
    if session[:started_at].blank?
      session[:started_at] = Time.now
    end
  end

  def set_variant
    request.variant = params[:variant].try(:to_sym)
  end

  User::Roles.each do |role|
    define_method("#{role}_only") do
      if !CurrentUser.user.send("is_#{role}?") || CurrentUser.user.is_banned? || IpBan.is_banned?(CurrentUser.ip_addr)
        access_denied
      end
    end
  end

  def set_title
    @page_title = Danbooru.config.app_name + "/#{params[:controller]}"
  end

  # Remove blank `search` params from the url.
  #
  # /tags?search[name]=touhou&search[category]=&search[order]=
  # => /tags?search[name]=touhou
  def normalize_search
    return unless request.get?
    params[:search] ||= ActionController::Parameters.new

    deep_reject_blank = lambda do |hash|
      hash.reject { |k, v| v.blank? || (v.is_a?(Hash) && deep_reject_blank.call(v).blank?) }
    end
    nonblank_search_params = deep_reject_blank.call(params[:search])

    if nonblank_search_params != params[:search]
      params[:search] = nonblank_search_params
      redirect_to url_for(params: params.except(:controller, :action, :index).permit!)
    end
  end

  def search_params
    params.fetch(:search, {}).permit!
  end

  def set_safe_mode
    CurrentUser.set_safe_mode(request)
  end
end
