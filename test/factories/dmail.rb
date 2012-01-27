Factory.define(:dmail) do |f|
  f.to {|x| x.association(:user)}
  f.title {Faker::Lorem.words.join(" ")}
  f.body {Faker::Lorem.sentences.join(" ")}
end
