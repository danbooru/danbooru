FactoryBot.define do
  factory(:post_appeal) do
    creator
    post { build(:post, is_deleted: true) }
    reason {"xxx"}
  end
end
