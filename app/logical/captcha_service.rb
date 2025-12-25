# A service for protecting forms with captchas using Cloudflare Turnstile.
#
# To use it, put `captcha_tag` inside a form to generate the captcha widget, then use `verify_request` in the
# controller to verify that the captcha was solved.
#
# @see https://developers.cloudflare.com/turnstile/
class CaptchaService
  include ActionView::Helpers::TagHelper

  class Error < StandardError; end

  attr_reader :api_url, :site_key, :secret_key, :http

  def initialize(site_key: Danbooru.config.captcha_site_key, secret_key: Danbooru.config.captcha_secret_key, http: Danbooru::Http.external, api_url: "https://challenges.cloudflare.com/turnstile/v0/siteverify")
    @api_url = api_url
    @site_key = site_key
    @secret_key = secret_key
    @http = http
  end

  def enabled?
    site_key.present? && secret_key.present?
  end

  # Render the captcha widget. This should be used inside a form. The <div> will be replaced by a captcha widget that,
  # when solved, will insert a hidden `cf-turnstile-response` field inside the form. This field is then verified server-side.
  #
  # @param class [String] The CSS class(es) to add to the widget.
  # @param current_user [User] The current user.
  # @param options [Hash] A hash of data-* attribute options to pass to the captcha widget.
  # @see https://developers.cloudflare.com/turnstile/get-started/client-side-rendering/#configurations
  def captcha_tag(class: "", current_user: CurrentUser.user, **options)
    return nil if !enabled?

    <<~EOS.html_safe
      <script src="https://challenges.cloudflare.com/turnstile/v0/api.js" async defer crossorigin></script>
      #{tag.div(class: "cf-turnstile #{binding.local_variable_get(:class)}", data: { sitekey: site_key, theme: current_user.theme, callback: "onCaptchaComplete", **options })}
    EOS
  end

  # Verify that a request protected by a captcha is allowed. Returns true if the captcha was successfully solved, or
  # raises an error if not. If the captcha service isn't enabled, or if the API call fails with an unexpected error,
  # then always returns true to allow all requests through.
  #
  # @param request [ActionDispatch::Request] The HTTP request to verify.
  def verify_request!(request)
    return true if !enabled?

    token = request.params["cf-turnstile-response"]
    response = request(remoteip: request.remote_ip.to_s, response: token, sitekey: site_key, secret: secret_key)

    raise Error, "Missing or invalid captcha (#{response["error-codes"].join("; ")})" if response["success"] == false
    true
  end

  # Like `verify_request!`, but returns false instead of raising an error if the request isn't verified.
  def verify_request(...)
    verify_request!(...)
  rescue Error
    false
  end

  # https://developers.cloudflare.com/turnstile/get-started/server-side-validation
  def request(**params)
    http.parsed_post(api_url, form: params).to_h
  end
end
