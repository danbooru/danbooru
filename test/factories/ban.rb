Factory.define(:ban) do |f|
  f.reason {Faker::Lorem.words.join(" ")}
  f.duration 60
end
