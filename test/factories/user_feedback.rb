Factory.define(:user_feedback) do |f|
  f.is_positive true
  f.body {Faker::Lorem.words}
end
