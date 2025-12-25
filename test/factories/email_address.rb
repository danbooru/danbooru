FactoryBot.define do
  factory(:email_address) do
    address { Faker::Internet.unique.email }
    is_verified { true }
    user
  end
end
