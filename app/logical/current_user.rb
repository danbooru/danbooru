# frozen_string_literal: true

# A global variable containing the current user, the current request, whether
# safe mode is enabled, and whether save-data mode is enabled.
#
# The current user is set during a request by {ApplicationController#set_current_user},
# which calls {SessionLoader#load}. The current user will not be set outside of
# the request cycle, for example, during background jobs, cron jobs, or on the
# console. For this reason, code outside of controllers and views, such as
# models, shouldn't rely on or assume the current user exists.
#
# @see https://api.rubyonrails.org/classes/ActiveSupport/CurrentAttributes.html
# @see ApplicationController#set_current_user
# @see SessionLoader#load
class CurrentUser < ActiveSupport::CurrentAttributes
  attribute :user, :safe_mode, :save_data, :request

  alias_method :safe_mode?, :safe_mode
  delegate :id, to: :user, allow_nil: true
  delegate_missing_to :user

  # Run a block of code as another user.
  # @param user [User] the user to run as
  # @param ip_addr [String] the IP address to run as
  # @yield the block
  def self.scoped(user, ip_addr = "127.0.0.1", &block)
    set(user: user) do
      yield user
    end
  end
end
