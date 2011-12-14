Factory.define(:note) do |f|
  f.creator {|x| x.association(:user)}
  f.post {|x| x.association(:post)}
  f.x 0
  f.y 0
  f.width 0
  f.height 0
  f.is_active true
  f.body {Faker::Lorem.sentences.join}
  f.updater_id {|x| x.association(:user)}
  f.updater_ip_addr "127.0.0.1"
end
