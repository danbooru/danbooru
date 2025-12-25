FactoryBot.define do
  factory(:tag_version) do
    tag factory: :tag
    updater factory: :user
    name { Faker::Lorem.words }
    version { 1 }
    category { TagCategory::GENERAL }
    is_deprecated { false }
  end
end
