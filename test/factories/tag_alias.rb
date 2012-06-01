FactoryGirl.define do
  factory :tag_alias do
    antecedent_name "aaa"
    consequent_name "bbb"
    
    after(:create) do |tag_alias|
      tag_alias.process!
    end
  end
end
