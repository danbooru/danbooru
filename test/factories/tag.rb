Factory.define(:tag) do |f|
  f.name {Faker::Name.first_name}
  f.post_count 0
  f.category Tag.categories.general
  f.related_tags ""
end

Factory.define(:artist_tag, :parent => :tag) do |f|
  f.category Tag.categories.artist
end
