class ApplicationController < ActionController::Base
  include Pundit
  helper_method :search_params

  self.responder = ApplicationResponder

  skip_forgery_protection if: -> { SessionLoader.new(request).has_api_authentication? }
  before_action :reset_current_user
  before_action :set_current_user
  before_action :normalize_search
  before_action :check_rate_limit
  before_action :ip_ban_check
  before_action :set_variant
  before_action :add_headers
  before_action :cause_error
  after_action :skip_session_if_publicly_cached
  after_action :reset_current_user
  layout "default"

  rescue_from Exception, :with => :rescue_exception

  def self.rescue_with(*klasses, status: 500)
    rescue_from(*klasses) do |exception|
      render_error_page(status, exception)
    end
  end

  private

  def respond_with(subject, *args, model: model_name, **options, &block)
    if params[:action] == "index" && is_redirect?(subject)
      redirect_to_show(subject)
      return
    end

    if subject.respond_to?(:includes) && (request.format.json? || request.format.xml?)
      associations = ParameterBuilder.includes_parameters(params[:only], model)
      subject = subject.includes(associations)
    end

    @current_item = subject
    super
  end

  def set_version_comparison(default_type = "previous")
    params[:type] = %w[previous subsequent current].include?(params[:type]) ? params[:type] : default_type
  end

  def model_name
    controller_name.classify
  end

  def redirect_to_show(items)
    redirect_to send("#{controller_path.singularize}_path", items.first, format: request.format.symbol)
  end

  def is_redirect?(items)
    action_methods.include?("show") && params[:redirect].to_s.truthy? && items.one? && item_matches_params(items.first)
  end

  def item_matches_params(*)
    true
  end

  protected

  def add_headers
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["X-Git-Hash"] = Rails.application.config.x.git_hash
  end

  def check_rate_limit
    return if request.get? || request.head?

    rate_limiter = RateLimiter.for_action(controller_name, action_name, CurrentUser.user, CurrentUser.ip_addr)
    headers["X-Rate-Limit"] = rate_limiter.to_json

    rate_limiter.limit!
  end

  def rescue_exception(exception)
    case exception
    when ActionView::Template::Error
      rescue_exception(exception.cause)
    when ActiveRecord::QueryCanceled
      render_error_page(500, exception, template: "static/search_timeout", message: "The database timed out running your query.")
    when ActionController::BadRequest
      render_error_page(400, exception)
    when SessionLoader::AuthenticationFailure
      render_error_page(401, exception, template: "sessions/new")
    when ActionController::InvalidAuthenticityToken, ActionController::UnpermittedParameters, ActionController::InvalidCrossOriginRequest
      render_error_page(403, exception)
    when ActiveSupport::MessageVerifier::InvalidSignature, # raised by `find_signed!`
         User::PrivilegeError,
         Pundit::NotAuthorizedError
      render_error_page(403, exception, template: "static/access_denied", message: "Access denied")
    when ActiveRecord::RecordNotFound
      render_error_page(404, exception, message: "That record was not found.")
    when ActionController::RoutingError
      render_error_page(405, exception)
    when ActionController::UnknownFormat, ActionView::MissingTemplate
      render_error_page(406, exception, message: "#{request.format} is not a supported format for this page")
    when PaginationExtension::PaginationError
      render_error_page(410, exception, template: "static/pagination_error", message: "You cannot go beyond page #{CurrentUser.user.page_limit}.")
    when PostQueryBuilder::TagLimitError
      render_error_page(422, exception, template: "static/tag_limit_error", message: "You cannot search for more than #{CurrentUser.tag_query_limit} tags at a time.")
    when RateLimiter::RateLimitError
      render_error_page(429, exception)
    when Rack::Timeout::RequestTimeoutException
      render_error_page(500, exception, message: "Your request took too long to complete and was canceled.")
    when NotImplementedError
      render_error_page(501, exception, message: "This feature isn't available: #{exception.message}")
    when PG::ConnectionBad
      render_error_page(503, exception, message: "The database is unavailable. Try again later.")
    else
      raise exception if !Rails.env.production? || Danbooru.config.debug_mode
      render_error_page(500, exception)
    end
  end

  def render_error_page(status, exception = nil, message: exception.message, template: "static/error", format: request.format.symbol)
    @exception = exception
    @expected = status < 500
    @message = message.encode("utf-8", invalid: :replace, undef: :replace)
    @backtrace = Rails.backtrace_cleaner.clean(@exception.backtrace) if @exception
    format = :html unless format.in?(%i[html json xml js atom])

    # if InvalidAuthenticityToken was raised, CurrentUser isn't set so we have to use the blank layout.
    layout = CurrentUser.user.present? ? "default" : "blank"

    DanbooruLogger.log(@exception, expected: @expected) if @exception
    render template, layout: layout, status: status, formats: format
  rescue ActionView::MissingTemplate
    render "static/error", layout: layout, status: status, formats: format
  end

  def set_current_user
    SessionLoader.new(request).load
  end

  def reset_current_user
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
    CurrentUser.safe_mode = false
  end

  # Skip setting the session cookie if the response is being publicly cached to
  # prevent the user's session cookie from being leaked to other users.
  def skip_session_if_publicly_cached
    if response.cache_control[:public] == true
      request.session_options[:skip] = true
    end
  end

  def set_variant
    request.variant = params[:variant].try(:to_sym)
  end

  # allow api clients to force errors for testing purposes.
  def cause_error
    return unless params[:cause_error].present?

    status = params[:cause_error].to_i
    raise ArgumentError, "invalid status code" unless status.in?(400..599)

    error = StandardError.new(params[:message])
    error.set_backtrace(caller)

    render_error_page(status, error)
  end

  def ip_ban_check
    raise User::PrivilegeError if !request.get? && IpBan.hit!(:full, CurrentUser.ip_addr)
  end

  def pundit_user
    CurrentUser.user
  end

  def pundit_params_for(record)
    params.fetch(PolicyFinder.new(record).param_key, {})
  end

  def requires_reauthentication
    return if CurrentUser.user.is_anonymous?

    last_authenticated_at = session[:last_authenticated_at]
    if last_authenticated_at.blank? || Time.zone.parse(last_authenticated_at) < 60.minutes.ago
      redirect_to confirm_password_session_path(url: request.fullpath)
    end
  end

  # Remove blank `search` params from the url.
  #
  # /tags?search[name]=touhou&search[category]=&search[order]=
  # => /tags?search[name]=touhou
  def normalize_search
    return unless request.get? || request.head?
    params[:search] ||= ActionController::Parameters.new

    deep_reject_blank = lambda do |hash|
      hash.reject { |_k, v| v.blank? || (v.is_a?(Hash) && deep_reject_blank.call(v).blank?) }
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
end
