FactoryBot.define do
  factory(:upload_media_asset) do
    upload
    media_asset
    source_url { Faker::Internet.url }
  end
end
