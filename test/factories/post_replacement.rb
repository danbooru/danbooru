FactoryBot.define do
  factory(:post_replacement) do
    original_url { FFaker::Internet.http_url }
    replacement_url { FFaker::Internet.http_url }
  end
end
