FactoryBot.define do
  factory :post_appeal do
    creator
    post { association :post, is_deleted: true }
    reason { "xxx" }
  end
end
