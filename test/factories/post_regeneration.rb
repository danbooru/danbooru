FactoryBot.define do
  factory(:post_regeneration) do
    post factory: :post, source: FFaker::Internet.http_url
  end
end
