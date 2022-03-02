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
      level {10}
      requires_verification { true }
      is_verified { false }
    end

    factory(:member_user) do
      level {20}
    end

    factory(:gold_user) do
      level {30}
    end

    factory(:platinum_user) do
      level {31}
    end

    factory(:builder_user) do
      level {32}
    end

    factory(:contributor_user) do
      level {32}
      can_upload_free {true}
    end

    factory(:contrib_user) do
      level {32}
      can_upload_free {true}
    end

    factory(:moderator_user) do
      level {40}
      can_approve_posts {true}
    end

    factory(:mod_user) do
      level {40}
      can_approve_posts {true}
    end

    factory(:admin_user) do
      level {50}
      can_approve_posts {true}
    end

    factory(:owner_user) do
      level { User::Levels::OWNER }
      can_approve_posts {true}
    end

    factory(:uploader) do
      created_at { 2.weeks.ago }
    end

    factory(:approver) do
      level {32}
      can_approve_posts {true}
    end
  end
end
