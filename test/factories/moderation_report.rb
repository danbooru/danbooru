FactoryBot.define do
  factory(:moderation_report) do
    creator
    reason {"xxx"}
    status { :pending }
    model { build(:comment) }
  end
end
