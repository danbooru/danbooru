FactoryBot.define do
  factory :media_metadata do
    media_asset { association :media_asset, media_metadata: instance }
    metadata { MediaFile.open("test/files/test.jpg").metadata }
  end
end
