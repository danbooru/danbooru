# Be sure to restart your server when you modify this file.

# https://api.rubyonrails.org/classes/ActionDispatch/Cookies.html
Rails.application.config.session_store(
  :cookie_store,
  key: Danbooru.config.session_cookie_name,
  domain: Danbooru.config.session_cookie_domain,
  same_site: :lax,
  secure: Rails.env.production? && Danbooru.config.canonical_url.match?(%r!\Ahttps://!)
)
