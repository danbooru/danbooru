FactoryBot.define do
  factory :tag_implication do
    antecedent_name "aaa"
    consequent_name "bbb"
    status "active"
    skip_secondary_validations true
    
    after(:create) do |tag_implication|
      unless tag_implication.status == "pending"
        approver = FactoryBot.create(:admin_user) unless approver.present?
        tag_implication.approve!(approver: approver)
      end
    end
  end
end
