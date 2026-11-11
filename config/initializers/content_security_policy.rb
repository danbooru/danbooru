# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  # The origin of the image server (e.g. "https://cdn.donmai.us"), or nil if images are served from a relative URL.
  # Procs are evaluated on each request.
  storage_host = -> { Danbooru::URL.parse(Danbooru.config.storage_manager.base_url)&.site }
  reportbooru_host = -> { Danbooru::URL.parse(Danbooru.config.reportbooru_server)&.site }

  # The webpack dev server's live reload websocket. It connects to ws://<current hostname>:3035/ws, so allow any host.
  # This also allows wss:// when the site is served over HTTPS.
  webpack_dev_server = -> { "ws://*:#{Shakapacker.dev_server.port}" if Rails.env.development? }

  config.content_security_policy do |policy|
    policy.default_src :self

    policy.base_uri   :self
    policy.object_src :none

    # :unsafe_eval is for Alpine.
    # :wasm_unsafe_eval is for the Ruffle player.
    # https://challenges.cloudflare.com is for Cloudflare Turnstile CAPTCHAs.
    policy.script_src :self, :unsafe_eval, :wasm_unsafe_eval, "challenges.cloudflare.com", "static.cloudflareinsights.com"

    # :blob is for Ugoira frames.
    # :data is for the DText external link icon and the autocorrect underline in CSS.
    policy.img_src :self, storage_host, :blob, :data
    policy.media_src :self, storage_host
    policy.connect_src :self, storage_host, reportbooru_host, webpack_dev_server, "cloudflareinsights.com"

    # Allow only same-origin <style> tags and `style="..."` attributes, not external stylesheets.
    policy.style_src :self, :unsafe_inline
    # policy.style_src :self, :https, :unsafe_inline # This would allow @import url(...) in custom CSS

    # Allow only same-origin fonts, not external fonts in custom CSS.
    policy.font_src :self
    # policy.font_src :self, :https # This would allow `@font-face { src: url(...) }` in custom CSS.

    # Allow same-origin <iframe>s and Cloudflare Turnstile CAPTCHAs. https://www.bing.com is also allowed in
    # IpAddressesController for Bing Maps.
    policy.frame_src :self, "https://challenges.cloudflare.com"

    # Allow being <iframe>'d in development (for VS Code and Codespaces), but not in production.
    policy.frame_ancestors :self unless Rails.env.local?

    policy.report_uri "/csp_reports"
  end

  # Generate a random nonce on each request. Inline <script> tags need `nonce="<%= content_security_policy_nonce %>"`.
  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  # Inline <script> tags must have a nonce. Inline event handlers and `javascript:` links are blocked.
  config.content_security_policy_nonce_directives = %w[script-src]
end
