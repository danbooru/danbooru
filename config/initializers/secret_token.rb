require File.expand_path('../../state_checker', __FILE__)

StateChecker.new.check!

Danbooru::Application.config.action_dispatch.session = {
  :key    => '_danbooru2_session',
  :secret => File.read(File.expand_path("~/.danbooru/session_secret_key"))
}
Danbooru::Application.config.secret_token = File.read(File.expand_path("~/.danbooru/secret_token"))
