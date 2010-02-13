Factory.define(:pool) do |f|
  f.name {Faker::Name.first_name}
  f.creator {|x| x.association(:user)}
  f.description {Faker::Lorem.sentences}
  f.updater_id {|x| x.creator_id}
  f.updater_ip_addr "127.0.0.1"
end
