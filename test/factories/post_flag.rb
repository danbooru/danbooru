FactoryBot.define do
  factory(:post_flag) do
    creator
    post { build(:post) }
    reason {"xxx"}
  end
end
