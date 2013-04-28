FactoryGirl.define do
  factory(:artist_url) do
    artist
    url {Faker::Internet.domain_name}
  end
end
