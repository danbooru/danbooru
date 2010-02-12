Factory.define(:tag_implication) do |f|
  f.creator {|x| x.association(:user)}
  f.updater_id {|x| x.creator_id}
  f.updater_ip_addr "127.0.0.1"
end
