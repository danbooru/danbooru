Factory.define(:wiki_page) do |f|
  f.creator {|x| x.association(:user)}
  f.title {|x| Faker::Lorem.words}
  f.body {Faker::Lorem.sentences}
  f.updater_id {|x| x.creator_id}
  f.updater_ip_addr "127.0.0.1"
end
