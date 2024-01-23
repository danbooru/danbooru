FactoryBot.define do
  factory(:user_name_change_request) do
    user
    original_name { Faker::Internet.username }
    desired_name { Faker::Internet.username }
  end
end
