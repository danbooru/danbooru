FactoryBot.define do
  factory(:upload_media_asset) do
    upload
    media_asset
    source_url { FFaker::Internet.http_url }
  end
end
