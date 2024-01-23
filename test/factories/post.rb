FactoryBot.define do
  factory(:post) do
    md5 { SecureRandom.hex(32) }
    uploader
    tag_string {"tag1 tag2"}
    tag_count {2}
    tag_count_general {2}
    file_ext {"jpg"}
    image_width {1500}
    image_height {1000}
    file_size {2000}
    rating {"q"}
    source { Faker::Internet.url }
    media_asset { build(:media_asset) }

    factory(:post_with_file) do
      transient do
        filename { "test.jpg" }
        media_file { MediaFile.open("test/files/#{filename}") }
      end

      md5 { media_file.md5 }
      image_width { media_file.width }
      image_height { media_file.height }
      file_ext { media_file.file_ext }
      file_size { media_file.file_size }
      media_asset { MediaAsset.upload!(media_file) }
    end
  end
end
