Factory.define(:comment) do |f|
  f.post {|x| x.association(:post)}
  f.body {Faker::Lorem.sentences.join(" ")}
end
