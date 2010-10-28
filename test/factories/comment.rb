Factory.define(:comment) do |f|
  f.post {|x| x.association(:post)}
  f.body {Faker::Lorem.sentences}
  f.score 0
end
