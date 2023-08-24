require "securerandom"

User.create(
  name: Danbooru.config.system_user,
  password: SecureRandom.base64(32),
  level: User::Levels::MODERATOR
)

# Create the rating:* tags for autotagging to be able to suggest them to users.
%w[g e q s].each do |rating|
  unless Tag.exists?(name: "rating:#{rating}")
    # We need to bypass validation here, since we can't normally create rating tags
    Tag.new(name: "rating:#{rating}").save(:validate => false)
  end
end
