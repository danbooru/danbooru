FactoryBot.define do
  factory(:user_feedback) do
    creator factory: :builder_user
    user
    category { "positive" }
    body { Faker::Lorem.paragraph }
  end
end
