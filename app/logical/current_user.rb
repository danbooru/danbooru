class CurrentUser < ActiveSupport::CurrentAttributes
  attribute :user, :ip_addr, :country, :safe_mode

  alias_method :safe_mode?, :safe_mode
  delegate :id, to: :user, allow_nil: true
  delegate_missing_to :user

  def self.scoped(user, ip_addr = "127.0.0.1", &block)
    set(user: user, ip_addr: ip_addr) do
      yield user
    end
  end
end
