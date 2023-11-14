FactoryBot.define do
  factory(:user, aliases: [:creator, :updater]) do
    name { SecureRandom.uuid.first(20) }
    password {"password"}
    level {20}
    last_logged_in_at {Time.now}

    factory(:banned_user) do
      transient { ban_duration {3} }
      is_banned {true}
      active_ban factory: :ban
    end

    factory(:restricted_user) do
      level {User::Levels::RESTRICTED}
      requires_verification { true }
      is_verified { false }
    end

    User.level_hash.each do |level_name, level_value|
      # allows create(:moderator_user), create(:approver) etc
      next if level_name == "Restricted"  # already defined above

      factory(level_name.downcase) do
        level {level_value}
      end

      factory("#{level_name.downcase}_user") do
        level {level_value}
      end
    end

    factory(:mod_user) do
      level {User::Levels::MODERATOR}
    end

    factory(:uploader) do
      created_at { 2.weeks.ago }
    end
  end
end
