Factory.define(:artist_url) do |f|
  f.artist {|x| x.association(:artist)}
  f.url {Faker::Internet.domain_name}
end
