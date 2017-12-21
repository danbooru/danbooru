require "securerandom"

system = User.find_or_create_by!(name: Danbooru.config.system_user) do |user|
  user.password = SecureRandom.base64(32)
end

unless system.is_moderator?
  system.level = User::Levels::MODERATOR
  system.save
end
