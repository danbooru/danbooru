Factory.define(:unapproval) do |f|
  f.post {|x| x.association(:post)}
end
