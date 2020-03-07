FactoryBot.define do
  factory(:post_flag) do
    creator
    post
    reason {"xxx"}
    is_resolved {false}
  end
end
