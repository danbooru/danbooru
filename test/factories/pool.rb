Factory.define(:pool) do |f|
  f.name {(rand(1_000_000) + 100).to_s}
  f.creator {|x| x.association(:user)}
  f.description {Faker::Lorem.sentences}
end
