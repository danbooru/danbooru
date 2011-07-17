Factory.define(:user_feedback) do |f|
  f.user {|x| x.association(:user)}
  f.category "positive"
  f.body {Faker::Lorem.words.join(" ")}
end
