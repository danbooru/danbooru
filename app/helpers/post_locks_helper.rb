module PostLocksHelper
  def post_lock_all_locks(post_lock)
    all_locks = []

    post_lock.class::ALL_TYPES.each do |flag|
      if post_lock.send("#{flag}_lock")
        all_locks << flag
      end
    end

    sanitize(all_locks.join("<br>"))
  end

  def post_lock_actions(post_lock)
    actions = []

    post_lock.class::ALL_TYPES.each do |flag|
      if post_lock.send("#{flag}_lock_changed")
        actions << (post_lock.send("#{flag}_lock") ? "#{flag}_locked" : "#{flag}_unlocked")
      end
    end

    actions << "duration set" if post_lock.duration_set
    actions << "level set" if post_lock.level_set
    sanitize(actions.join("<br>"))
  end

  def post_lock_expires_status(post_lock)
    if post_lock.expires_at > Time.now.utc
      time_ago_in_words post_lock.expires_at
    elsif post_lock.bit_flags == 0
      "Removed"
    elsif post_lock.expires_at.to_i == 0
      "Edited"
    else
      "Expired"
    end
  end

  def available_min_user_levels
    PostLock::MIN_LEVELS.select { |_name, level| level <= CurrentUser.level }.to_a
  end

  def post_lock_set_expiration(post_lock)
    days_duration = post_lock_days_duration(post_lock)

    if post_lock.new_record?
      days_duration = [days_duration, 7.0].max
    end

    "#{days_duration} days"
  end

  def post_lock_current_expiration(post_lock)
    if post_lock.new_record? && post_lock.present_lock.nil?
      "Unset"
    else
      "#{post_lock_days_duration(post_lock)} days"
    end
  end

  def post_lock_days_duration(post_lock)
    use_lock = post_lock.new_record? ? post_lock.present_lock : post_lock
    return 0.0 if use_lock.nil?

    seconds_duration = (use_lock.expires_at - Time.now.utc)
    (seconds_duration / (60 * 60 * 24)).ceil(1)
  end
end
