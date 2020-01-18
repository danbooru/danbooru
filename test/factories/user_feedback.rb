FactoryBot.define do
  factory(:user_feedback) do
    creator factory: :builder_user
    user
    category { "positive" }
    body { FFaker::Lorem.words.join(" ") }
  end
end
