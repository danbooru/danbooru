Factory.define(:pool) do |f|
  f.name {Faker::Name.first_name}
  f.creator {|x| x.association(:user)}
  f.description {Faker::Lorem.sentences}
end
