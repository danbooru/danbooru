FactoryBot.define do
  factory(:wiki_page) do
    title { Faker::Internet.unique.username }
    body { Faker::Lorem.paragraph }
  end
end
