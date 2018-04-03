FactoryBot.define do
  factory(:forum_topic) do
    title {FFaker::Lorem.words.join(" ")}
    is_sticky false
    is_locked false
    category_id 0

    factory(:mod_up_forum_topic) do
      min_level User::Levels::MODERATOR
    end
  end
end
