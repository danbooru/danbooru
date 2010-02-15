Factory.define(:artist_url) do |f|
  f.url {Faker::Internet.domain_name}
end
