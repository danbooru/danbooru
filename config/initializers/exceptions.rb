# This middleware normally swallows unhandled exceptions and displays an error page. Disable it so we can handle
# unexpected exceptions ourselves in `lowlevel_error_handler` in config/puma.rb.
#
# This only has an effect in production. When RAILS_ENV is development, errors are swallowed by the BetterErrors gem.
Rails.application.config.middleware.delete(ActionDispatch::ShowExceptions)
