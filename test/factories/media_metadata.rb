FactoryBot.define do
  # Reading the metadata runs ExifTool, which is slow, so only read it once.
  test_jpg_metadata = nil

  factory :media_metadata do
    media_asset { association :media_asset, media_metadata: instance }
    metadata { (test_jpg_metadata ||= MediaFile.open("test/files/jpg/test.jpg").metadata).deep_dup }
  end
end
