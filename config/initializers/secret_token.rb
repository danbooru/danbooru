require File.expand_path('../../state_checker', __FILE__)

StateChecker.instance.check!

Rails.application.config.action_dispatch.session = {
  :key    => '_danbooru2_session',
  :secret => StateChecker.instance.session_secret_key
}
Rails.application.config.secret_token = StateChecker.instance.secret_token
