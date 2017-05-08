FactoryGirl.define do
  factory(:user, aliases: [:creator, :updater]) do
    name {(rand(1_000_000) + 10).to_s}
    password "password"
    password_hash {User.sha1("password")}
    email {FFaker::Internet.email}
    default_image_size "large"
    base_upload_limit 10
    level 20
    created_at {Time.now}
    last_logged_in_at {Time.now}
    favorite_count 0
    bit_prefs 0

    factory(:banned_user) do
      transient { ban_duration 3 }
      is_banned true
      after(:create) { |user, ctx| create(:ban, user: user, duration: ctx.ban_duration) }
    end

    factory(:member_user) do
      level 20
    end

    factory(:gold_user) do
      level 30
    end

    factory(:platinum_user) do
      level 31
    end

    factory(:builder_user) do
      level 32
    end

    factory(:contributor_user) do
      level 32
      bit_prefs User.flag_value_for("can_upload_free")
    end

    factory(:contrib_user) do
      level 32
      bit_prefs User.flag_value_for("can_upload_free")
    end

    factory(:moderator_user) do
      level 40
      can_approve_posts true
    end

    factory(:mod_user) do
      level 40
      can_approve_posts true
    end

    factory(:admin_user) do
      level 50
      can_approve_posts true
    end
  end
end

