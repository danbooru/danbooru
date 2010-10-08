Factory.define(:tag_implication) do |f|
  f.creator {|x| x.association(:user)}
  f.creator_ip_addr "127.0.0.1"
end
