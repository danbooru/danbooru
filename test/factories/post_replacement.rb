FactoryBot.define do
  factory(:post_replacement) do
    post factory: :post, source: FFaker::Internet.http_url
    original_url { FFaker::Internet.http_url }
    replacement_url { FFaker::Internet.http_url }
  end
end
