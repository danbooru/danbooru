FactoryBot.define do
  factory(:bulk_update_request) do |f|
    user
    title {"xxx"}
    script {"create alias aaa -> bbb"}
    reason { Faker::Lorem.paragraph }
  end
end
