FactoryBot.define do
  factory(:pixiv_ugoira_frame_data) do
    post
    content_type { "image/jpeg" }
    data do
      [
        { "file" => "000000.jpg", "delay" => 200 },
        { "file" => "000001.jpg", "delay" => 200 },
      ]
    end
  end
end
