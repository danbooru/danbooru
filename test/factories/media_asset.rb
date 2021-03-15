FactoryBot.define do
  factory(:media_asset) do
    md5 { SecureRandom.hex(32) }
    file_ext { "jpg" }
    file_size { 1_000_000 }
    image_width { 1000 }
    image_height { 1000 }
  end
end
