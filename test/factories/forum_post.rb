Factory.define(:forum_post) do |f|
  f.body {Faker::Lorem.sentences}
end
