Factory.define(:artist) do |f|
  f.name {Faker::Name.first_name}
  f.creator {|x| x.association(:user)}
  f.is_active true
end
