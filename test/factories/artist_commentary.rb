FactoryBot.define do
  factory(:artist_commentary) do
    post factory: :post
    original_title { FFaker::Lorem.sentences.join(" ") }
    original_description { FFaker::Lorem.sentences.join(" ") }
    translated_title { FFaker::Lorem.sentences.join(" ") }
    translated_description { FFaker::Lorem.sentences.join(" ") }
  end
end
