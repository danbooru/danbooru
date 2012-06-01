FactoryGirl.define do
  factory(:user_feedback) do
    user
    category "positive"
    body {Faker::Lorem.words.join(" ")}
  end
end
