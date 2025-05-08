FactoryBot.define do
  factory :site_credential do
    creator
    site { "Pixiv" }
    credential { { phpsessid: "foo" } }
  end
end
