FactoryBot.define do
  factory(:api_key) do
    user
    name { FFaker::Name.first_name }
  end
end
