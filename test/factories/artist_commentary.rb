FactoryBot.define do
  factory(:artist_commentary) do
    post factory: :post
    original_title { Faker::Lorem.paragraph }
    original_description { Faker::Lorem.paragraph }
    translated_title { Faker::Lorem.paragraph }
    translated_description { Faker::Lorem.paragraph }
  end
end
