Factory.define(:tag_subscription) do |f|
  f.owner {|x| x.association(:user)}
  f.name {Faker::Lorem.words.join(" ")}
  f.is_visible_on_profile true
end
