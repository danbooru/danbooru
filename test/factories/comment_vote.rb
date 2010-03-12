Factory.define(:comment_vote) do |f|
  f.comment {|x| x.association(:comment)}
  f.user {|x| x.association(:user)}
end
