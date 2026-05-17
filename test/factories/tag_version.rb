FactoryBot.define do
  factory :tag_version do
    tag
    updater factory: :user
    name { Faker::Lorem.words }
    version { 1 }
    category { Tag.categories.general }
    is_deprecated { false }
  end
end
