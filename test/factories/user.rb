FactoryBot.define do
  factory(:user, aliases: [:creator, :updater]) do
    name { SecureRandom.uuid }
    password {"password"}
    default_image_size {"large"}
    level {20}
    created_at {Time.now}
    last_logged_in_at {Time.now}
    favorite_count {0}
    bit_prefs {0}
    last_forum_read_at {nil}

    factory(:banned_user) do
      transient { ban_duration {3} }
      is_banned {true}
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

    factory(:uploader) do
      created_at { 2.weeks.ago }
    end

    factory(:approver) do
      level {32}
      can_approve_posts {true}
    end
  end
end
