FactoryGirl.define do
  factory(:saved_search) do
    tag_query { FFaker::Lorem.words }
    category { FFaker::Lorem.word }
    user
  end
end
