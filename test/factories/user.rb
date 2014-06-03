FactoryGirl.define do
  factory(:user) do
    name {(rand(1_000_000) + 10).to_s}
    password "password"
    password_hash {User.sha1("password")}
    email {Faker::Internet.email}
    default_image_size "large"
    base_upload_limit 10
    level 20
    last_logged_in_at {Time.now}
    favorite_count 0
    bit_prefs 0

    factory(:banned_user) do
      is_banned true
      ban {|x| x.association(:ban)}
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
      level 33
    end

    factory(:janitor_user) do
      level 35
    end

    factory(:moderator_user) do
      level 40
    end

    factory(:admin_user) do
      level 50
    end
  end
end

