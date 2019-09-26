FactoryBot.define do
  factory(:user_name_change_request) do
    user
    original_name {FFaker::Internet.user_name}
    desired_name {FFaker::Internet.user_name}
  end
end
