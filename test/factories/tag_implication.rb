FactoryGirl.define do
  factory :tag_implication do
    antecedent_name "aaa"
    consequent_name "bbb"
    status "active"
    skip_secondary_validations true
    
    after(:create) do |tag_implication|
      unless tag_implication.status == "pending"
        tag_implication.process!
      end
    end
  end
end
