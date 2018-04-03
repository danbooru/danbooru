FactoryBot.define do
  factory(:artist_url) do
    artist
    url {FFaker::Internet.domain_name}
  end
end
