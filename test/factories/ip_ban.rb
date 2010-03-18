Factory.define(:ip_ban) do |f|
  f.creator {|x| x.association(:user)}
  f.reason {Faker::Lorem.words}
  f.ip_addr "127.0.0.1"
end
