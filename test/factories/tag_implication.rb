FactoryGirl.define do
  factory :tag_implication do
    antecedent_name "aaa"
    consequent_name "bbb"
    
    after(:create) do |tag_implication|
      tag_implication.process!
    end
  end
end
