if Danbooru.config.amazon_ses && Rails.env == "production"
  Rails.application.config.action_mailer.smtp_settings = {
    :address => Danbooru.config.amazon_ses[:smtp_server_name],
    :user_name => Danbooru.config.amazon_ses[:ses_smtp_user_name],
    :password => Danbooru.config.amazon_ses[:ses_smtp_password],
    :authentication => :login,
    :enable_starttls_auto => true
  }
end
