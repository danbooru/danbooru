FactoryBot.define do
  factory(:post_flag) do
    creator
    post { build(:post, is_flagged: true) }
    reason {"xxx"}
  end
end
