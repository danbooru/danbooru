FactoryBot.define do
  factory(:dmail) do
    owner factory: :user
    from factory: :user
    to factory: :user
    title { Faker::Lorem.sentence }
    body { Faker::Lorem.paragraph }
  end
end
