FactoryBot.define do
  factory :tag_alias do
    creator
    antecedent_name { Faker::Internet.unique.username }
    consequent_name { Faker::Internet.unique.username }
    status {"active"}
  end
end
