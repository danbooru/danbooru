FactoryBot.define do
  factory :upload_media_asset do
    upload
    media_asset
    # An image URL, so post creation doesn't try to fetch the page (and wait on a DNS lookup for the fake host).
    source_url { "#{Faker::Internet.url}.jpg" }
  end
end
