Factory.define(:comment) do |f|
  f.creator {|x| x.association(:user)}
  f.post {|x| x.association(:post)}
  f.body {Faker::Lorem.sentences}
  f.ip_addr "127.0.0.1"
  f.score 0
end
