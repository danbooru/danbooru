Factory.define(:comment) do |f|
  f.post {|x| x.association(:post)}
  f.body {Faker::Lorem.sentences.join(" ")}
  f.score 0
end
