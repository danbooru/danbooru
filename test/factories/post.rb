FactoryBot.define do
  factory(:post) do
    md5 { SecureRandom.hex(32) }
    uploader
    uploader_ip_addr {"127.0.0.1"}
    tag_string {"tag1 tag2"}
    tag_count {2}
    tag_count_general {2}
    file_ext {"jpg"}
    image_width {1500}
    image_height {1000}
    file_size {2000}
    rating {"q"}
    source { FFaker::Internet.http_url }
  end
end
