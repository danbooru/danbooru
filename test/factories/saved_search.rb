FactoryBot.define do
  factory(:saved_search) do
    query { FFaker::Lorem.words }
    labels { [FFaker::Lorem.word] }
    user
  end
end
