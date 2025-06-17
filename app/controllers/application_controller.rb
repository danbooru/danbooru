# frozen_string_literal: true

class ApplicationController < ActionController::Base
  class PageRemovedError < StandardError; end
  class RequestBodyNotAllowedError < StandardError; end

  include Pundit::Authorization
  helper_method :search_params, :permitted_attributes

  self.responder = ApplicationResponder

  skip_forgery_protection if: -> { SessionLoader.new(request).has_api_authentication? }
  before_action :check_get_body
  before_action :reset_current_user
  before_action :set_current_user
  before_action :normalize_search
  before_action :ip_ban_check
  before_action :set_variant
  before_action :add_headers
  before_action :cause_error
  before_action :redirect_if_name_invalid?
  after_action :verify_authorized, if: -> { Rails.env.local? }
  after_action :skip_session_if_publicly_cached
  after_action :reset_current_user
  layout "default"

  rescue_from Exception, :with => :rescue_exception

  def self.rescue_with(*klasses, status: 500)
    rescue_from(*klasses) do |exception|
      render_error_page(status, exception)
    end
  end

  # Mark an action as for anonymous users only. The current user won't be loaded, instead the user will be set to the anonymous user.
  def self.anonymous_only(*actions, **options)
    skip_before_action :set_current_user, **options
    skip_before_action :redirect_if_name_invalid?, **options
    before_action -> { CurrentUser.user = User.anonymous }, **options
  end

  def self.verify_captcha(**options)
    before_action -> { CaptchaService.new.verify_request!(request) }, **options
  end

  private

  # Responds to a request and returns either an HTML, JS, JSON, or XML response, depending on the requested response format.
  #
  # If the model has errors, an error notice will be shown for HTML or JS responses.
  #
  # @param subject [ActiveRecord::Base, ActiveRecord::Relation>] The model or collection to return in response.
  # @param notice [String, nil] An optional notice message to display for HTML or JS responses. The notice should be in DText.
  #
  # @see https://github.com/heartcombo/responders
  def respond_with(subject, *args, model: model_name, notice: nil, **options, &block)
    if params[:redirect].to_s.present? && params[:action] == "index" && action_methods.include?("show")
      redirect_to_show(subject) and return
    end

    if subject.respond_to?(:includes) && (request.format.json? || request.format.xml?)
      associations = ParameterBuilder.includes_parameters(params[:only], model)
      subject = subject.includes(associations)
    end

    if subject.respond_to?(:errors) && subject.errors.present?
      notice = subject.errors.full_messages.first
    end

    if notice.present? && (request.format.html? || request.format.js?)
      if request.format.html? && !request.get?
        flash[:notice] = notice.truncate(500)
      elsif request.format.js?
        flash.now[:notice] = DText.new(notice.truncate(500), inline: true).format_text
      else
        flash.now[:notice] = notice.truncate(500)
      end
    end

    @current_item = subject

    super
  end

  # Used to redirect a search directly to the result page when a search returns only one result.
  # Example: /wiki_pages?search[title]=touhou&redirect=true.
  def redirect_to_show(items)
    if params[:redirect].to_s.truthy? && items.one? && item_matches_params(items.sole)
      format = request.format.symbol unless request.format.html?
      redirect_to send("#{controller_path.singularize}_path", items.sole, variant: params[:variant], format: format)
      true
    else
      false
    end
  end

  def set_version_comparison(default_type = "previous")
    params[:type] = %w[previous current].include?(params[:type]) ? params[:type] : default_type
  end

  def model_name
    controller_name.classify
  end

  def item_matches_params(*)
    true
  end

  protected

  def add_headers
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["X-Git-Hash"] = Rails.application.config.x.git_hash
  end

  concerning :ExceptionHandlingMethods do
    def rescue_exception(exception)
      case exception
      when ActionView::Template::Error
        rescue_exception(exception.cause)
      when ActiveRecord::QueryCanceled
        render_error_page(500, exception, template: "static/search_timeout", message: "The database timed out running your query.")
      when ActionController::BadRequest
        render_error_page(400, exception, message: exception.message)
      when RequestBodyNotAllowedError
        render_error_page(400, exception, message: "Request body not allowed for #{request.method} request")
      when SessionLoader::AuthenticationFailure, CaptchaService::Error
        render_error_page(401, exception, message: exception.message)
      when ActionController::InvalidAuthenticityToken, ActionController::UnpermittedParameters, ActionController::InvalidCrossOriginRequest, ActionController::Redirecting::UnsafeRedirectError
        render_error_page(403, exception, message: exception.message)
      when ActiveSupport::MessageVerifier::InvalidSignature, # raised by `find_signed!`
          User::PrivilegeError,
          Pundit::NotAuthorizedError
        render_error_page(403, exception, template: "static/access_denied", message: "Access denied")
      when ActiveRecord::RecordNotFound
        render_error_page(404, exception, message: "That record was not found.")
      when ActionController::RoutingError
        render_error_page(405, exception, message: exception.message)
      when ActionController::UnknownFormat, ActionView::MissingTemplate
        render_error_page(406, exception, message: "#{request.format} is not a supported format for this page")
      when PaginationExtension::PaginationError
        render_error_page(410, exception, template: "static/pagination_error", message: exception.message)
      when PostQuery::TagLimitError
        render_error_page(422, exception, template: "static/tag_limit_error", message: "You cannot search for more than #{CurrentUser.tag_query_limit} tags at a time.")
      when PostQuery::Error
        render_error_page(422, exception, message: exception.message)
      when UpgradeCode::InvalidCodeError, UpgradeCode::RedeemedCodeError, UpgradeCode::AlreadyUpgradedError
        render_error_page(422, exception, message: exception.message)
      when RateLimiter::RateLimitError
        render_error_page(429, exception, message: "You're doing that too fast. Wait a minute and try again.")
      when PageRemovedError
        render_error_page(451, exception, template: "static/page_removed_error", message: "This page has been removed because of a takedown request")
      when Rack::Timeout::RequestTimeoutException
        render_error_page(500, exception, message: "Your request took too long to complete and was canceled.")
      when NotImplementedError
        render_error_page(501, exception, message: "This feature isn't available: #{exception.message}")
      when ActiveRecord::ConnectionNotEstablished, PG::ConnectionBad
        render_error_page(503, exception, message: "The database is unavailable. Try again later.", layout: "blank")
      else
        raise exception if Rails.env.development? || Danbooru.config.debug_mode
        render_error_page(500, exception)
      end
    end

    def render_error_page(status, exception = nil, message: "", template: "static/error", format: request.format.symbol, layout: "default")
      @exception = exception
      @expected = status < 500
      @message = message.to_s.encode("utf-8", invalid: :replace, undef: :replace)
      @backtrace = Rails.backtrace_cleaner.clean(@exception.backtrace) if @exception
      format = :html unless format.in?(%i[html json xml js atom])

      @api_response = { success: false, error: @exception.class.to_s, message: @message, backtrace: @backtrace }

      # if InvalidAuthenticityToken was raised, CurrentUser isn't set so we have to use the blank layout.
      layout = "blank" if CurrentUser.user.nil?

      if @exception
        DanbooruLogger.log(@exception, expected: @expected)

        ApplicationMetrics[:rails_exceptions_total][
          exception: @exception.class.name,
          controller: controller_name,
          action: action_name,
          expected: @expected.to_s,
        ].increment
      end

      render template, layout: layout, status: status, formats: format
    rescue ActionView::MissingTemplate
      render "static/error", layout: layout, status: status, formats: format
    end
  end

  concerning :AuthenticationMethods do
    def set_current_user
      CurrentUser.request = request
      SessionLoader.new(request).load
    end

    def reset_current_user
      CurrentUser.user = nil
      CurrentUser.safe_mode = false
      CurrentUser.request = nil
    end
  end

  concerning :AuthorizationMethods do
    # Checks whether the current user is authorized to perform the current action. Also checks the rate limit for the action.
    #
    # @param record [ActiveRecord::Base, ActiveRecord::Relation] The record to authorize.
    # @param action [String, nil] The name of the action to authorize. Defaults to the controller action name.
    # @param policy_class [Class, nil] The policy class to use. If nil, the policy class will be determined by the record.
    # @return [ActiveRecord::Base, ActiveRecord::Relation] The authorized record.
    # @raise [Pundit::NotAuthorizedError] If the user is not authorized to perform the action.
    # @see https://github.com/varvet/pundit
    def authorize(record, action = nil, policy_class: nil)
      super
      check_rate_limit(record, policy_class: policy_class)
      record
    end

    # Checks the rate limit for the current controller action. Looks up the corresponding policy class and calls
    # `rate_limit_for_<action>` if it exists, or `rate_limit_for_read` or `rate_limit_for_write` if not.
    #
    # @raise [RateLimiter::RateLimitError] If the rate limit is exceeded.
    def check_rate_limit(record, policy_class: nil)
      policy = find_policy(record, policy_class: policy_class)
      rate_limit = policy.rate_limit(action_name, request)
      return if rate_limit.blank?

      key = "#{controller_name}:#{action_name}"
      rate_limiter = RateLimiter.build(action: key, **rate_limit.to_h, user: CurrentUser.user, request: request)

      headers["X-Rate-Limit"] = rate_limiter.to_json
      rate_limiter.limit!
    end

    def find_policy(record, policy_class: nil)
      if policy_class
        policy_class.new(pundit_user, record)
      else
        pundit.policy!(record)
      end
    end
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

  def check_get_body
    if request.body&.size.to_i > 0 && (request.get? || request.head? || request.options?) && request.method == request.request_method
      raise RequestBodyNotAllowedError
    end
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

  def redirect_if_name_invalid?
    if request.format.html? && !CurrentUser.user.is_anonymous? && CurrentUser.user.name_invalid?
      flash[:notice] = "You must change your username to continue using #{Danbooru.config.app_name}"
      redirect_to change_name_user_path(CurrentUser.user)
    end
  end

  def ip_ban_check
    raise User::PrivilegeError if !request.get? && IpBan.hit!(:full, request.remote_ip)
  end

  def pundit_user
    CurrentUser.user
  end

  def pundit_params_for(record)
    params.fetch(Pundit::PolicyFinder.new(record).param_key, {})
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
    params[:search] = ActionController::Parameters.new unless params[:search].is_a?(ActionController::Parameters)

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
