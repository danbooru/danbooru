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

  def self.as(user_or_id, &block)
    if user_or_id.is_a?(String) || user_or_id.is_a?(Integer)
      user = ::User.find(user_or_id)
    else
      user = user_or_id
    end

    scoped(user, &block)
  end
end
