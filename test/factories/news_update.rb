FactoryBot.define do
  factory(:news_update) do
    creator
    message {"xxx"}
    duration { 7.days }
  end
end
