Factory.define(:tag_alias) do |f|
  f.creator {|x| x.association(:user)}
  f.creator_ip_addr "127.0.0.1"
end
