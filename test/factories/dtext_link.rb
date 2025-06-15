FactoryBot.define do
  factory(:dtext_link) do
    model { build(:wiki_page) }
    link_type { "external_link" }
    link_target { Faker::Internet.url }
  end
end
