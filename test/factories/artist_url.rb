FactoryBot.define do
  factory(:artist_url) do
    artist
    url { Faker::Internet.unique.url }
  end
end
