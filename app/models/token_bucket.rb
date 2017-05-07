class TokenBucket < ActiveRecord::Base
  self.primary_key = "user_id"
  belongs_to :user

  def self.prune!
    where("last_touched_at < ?", 1.day.ago).delete_all
  end

  def self.create_default(user)
    TokenBucket.create(user_id: user.id, token_count: user.api_burst_limit, last_touched_at: Time.now)
  end

  def accept?
    token_count >= 1
  end

  def add!
    now = Time.now
    TokenBucket.where(user_id: user_id).update_all(["token_count = least(token_count + (? * extract(epoch from ? - last_touched_at)), ?), last_touched_at = ?", user.api_regen_multiplier, now, user.api_burst_limit, now])

    # estimate the token count to avoid reloading
    self.token_count += user.api_regen_multiplier * (now - last_touched_at)
    self.token_count = user.api_burst_limit if token_count > user.api_burst_limit
  end

  def consume!
    TokenBucket.where(user_id: user_id).update_all("token_count = greatest(0, token_count - 1)")
    self.token_count -= 1
  end

  def throttled?
    add!

    if accept?
      consume!
      return false
    else
      return true
    end
  end
end
