Factory.define(:janitor_trial) do |f|
  f.user {|x| x.association(:user)}
end
