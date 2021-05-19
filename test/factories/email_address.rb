FactoryBot.define do
  factory(:email_address) do
    address { FFaker::Internet.email }
    is_verified { true }
    user
  end
end
