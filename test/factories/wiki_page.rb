Factory.define(:wiki_page) do |f|
  f.creator {|x| x.association(:user)}
  f.title {|x| Faker::Lorem.words}
  f.body {Faker::Lorem.sentences}
end
