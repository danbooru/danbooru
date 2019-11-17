FactoryBot.define do
  factory :tag_alias do
    antecedent_name {"aaa"}
    consequent_name {"bbb"}
    status {"active"}
    skip_secondary_validations {true}
  end
end
