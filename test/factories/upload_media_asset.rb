FactoryBot.define do
  factory :upload_media_asset do
    upload
    media_asset
    user { upload.uploader }
    source_url { Faker::Internet.url }
  end
end
