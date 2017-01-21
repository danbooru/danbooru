require File.expand_path('../../state_checker', __FILE__)

StateChecker.check!

Rails.application.config.action_dispatch.session = {
  :key    => '_danbooru2_session',
  :secret => StateChecker.session_secret_key
}
Rails.application.config.secret_token = StateChecker.secret_token
