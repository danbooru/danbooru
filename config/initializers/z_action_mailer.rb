if Danbooru.config.aws_ses_enabled? && Rails.env == "production"
  Rails.application.config.action_mailer.smtp_settings = {
    :address => Danbooru.config.aws_ses_options[:smtp_server_name],
    :user_name => Danbooru.config.aws_ses_options[:ses_smtp_user_name],
    :password => Danbooru.config.aws_ses_options[:ses_smtp_password],
    :authentication => :login,
    :enable_starttls_auto => true
  }
end
