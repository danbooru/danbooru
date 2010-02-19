Factory.define(:ban) do |f|
  f.user {|x| x.association(:user)}
  f.banner {|x| x.association(:admin_user)}
  f.reason {Faker::Lorem.words}
  f.duration 60
end
