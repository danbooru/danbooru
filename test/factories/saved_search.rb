FactoryBot.define do
  factory(:saved_search) do
    query { Faker::Lorem.words }
    labels { [Faker::Lorem.word] }
    user
  end
end
