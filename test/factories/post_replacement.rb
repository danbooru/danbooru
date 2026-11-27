FactoryBot.define do
  factory :post_replacement do
    post factory: :post, source: Faker::Internet.url
    original_url { Faker::Internet.url }
    replacement_url { "" }
    creator
    media_asset
    md5 { media_asset.md5 }
    file_ext { media_asset.file_ext }
    file_size { media_asset.file_size }
    image_width { media_asset.image_width }
    image_height { media_asset.image_height }

    after(:build) do |replacement|
      replacement.define_singleton_method(:process!) { nil }
    end
  end
end
