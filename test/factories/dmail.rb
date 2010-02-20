Factory.define(:dmail) do |f|
  f.owner {|x| x.association(:user)}
  f.from_id {|x| x.owner_id}
  f.to {|x| x.association(:user)}
  f.title {Faker::Lorem.words}
  f.body {Faker::Lorem.sentences}
  f.is_read false
end
