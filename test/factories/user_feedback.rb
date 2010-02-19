Factory.define(:user_feedback) do |f|
  f.user {|x| x.association(:user)}
  f.creator {|x| x.association(:user)}
  f.is_positive true
  f.body {Faker::Lorem.words}
end
