Recaptcha.configure do |config|
  config.site_key   = Danbooru.config.recaptcha_site_key
  config.secret_key = Danbooru.config.recaptcha_secret_key
  # config.proxy = "http://example.com"
end
