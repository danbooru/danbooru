Factory.define(:forum_post) do |f|
  f.creator {|x| x.association(:user)}
  f.body {Faker::Lorem.sentences}
end
