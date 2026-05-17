FactoryBot.define do
  factory :dtext_link do
    model factory: :wiki_page
    link_type { "external_link" }
    link_target { Faker::Internet.url }
  end
end
