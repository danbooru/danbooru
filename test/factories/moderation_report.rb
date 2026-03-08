FactoryBot.define do
  factory :moderation_report do
    creator
    reason { "xxx" }
    status { :pending }
    model factory: :comment
  end
end
