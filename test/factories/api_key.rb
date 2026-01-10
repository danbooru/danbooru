FactoryBot.define do
  factory(:api_key) do
    user
    name { Faker::Name.first_name }
  end
end
