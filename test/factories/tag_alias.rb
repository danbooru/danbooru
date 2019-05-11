FactoryBot.define do
  factory :tag_alias do
    antecedent_name {"aaa"}
    consequent_name {"bbb"}
    status {"active"}
    skip_secondary_validations {true}
    creator_ip_addr { FFaker::Internet.ip_v4_address }
  end
end
