Factory.define(:mod_action) do |f|
  f.creator {|x| x.association(:user)}
  f.description "1234"
end
