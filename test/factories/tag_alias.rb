FactoryBot.define do
  factory :tag_alias do
    creator
    antecedent_name {"#{FFaker::Name.first_name.downcase}#{rand(1000)}"}
    consequent_name {"#{FFaker::Name.first_name.downcase}#{rand(1000)}"}
    status {"active"}
    skip_secondary_validations {true}
  end
end
