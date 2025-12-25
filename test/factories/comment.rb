FactoryBot.define do
  factory(:comment) do |f|
    creator
    post
    body { Faker::Lorem.paragraph }
  end
end
