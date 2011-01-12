Factory.define(:forum_topic) do |f|
  f.title {Faker::Lorem.words}
  f.is_sticky false
  f.is_locked false
end
