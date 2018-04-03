FactoryBot.define do
  factory(:user_feedback) do
    user
    category "positive"
    body {FFaker::Lorem.words.join(" ")}
  end
end
