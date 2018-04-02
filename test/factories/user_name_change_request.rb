FactoryBot.define do
  factory(:user_name_change_request) do
    desired_name {FFaker::Internet.user_name}
    change_reason {FFaker::Lorem.sentence}
  end
end
