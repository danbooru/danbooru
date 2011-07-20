Factory.define(:tag_subscription) do |f|
  f.name {Faker::Lorem.words.join(" ")}
  f.is_public true
  f.tag_query "aaa"
end
