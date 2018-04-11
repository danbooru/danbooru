FactoryBot.define do
  factory :tag_alias do
    antecedent_name "aaa"
    consequent_name "bbb"
    status "active"
    skip_secondary_validations true
    creator_ip_addr { FFaker::Internet.ip_v4_address }

    after(:create) do |tag_alias|
      unless tag_alias.status == "pending"
        approver = FactoryBot.create(:admin_user) unless approver.present?
        tag_alias.approve!(approver: approver)
      end
    end
  end
end
