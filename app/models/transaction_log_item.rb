class TransactionLogItem < ActiveRecord::Base
  attr_accessible :category, :data, :user_id
  validates_inclusion_of :category, :in => %w(
    account_upgrade_basic_to_gold 
    account_upgrade_basic_to_platinum 
    account_upgrade_gold_to_platinum
    account_upgrade_view
  )

  def self.record_account_upgrade_view(user, referrer)
    create(:category => "account_upgrade_view", :user_id => user.id, :data => referrer)
  end

  def self.record_account_upgrade(user)
    attributes = {:user_id => user.id}

    if user.level_was < User::Levels::PLATINUM && user.level == User::Levels::PLATINUM
      attributes[:category] = "account_upgrade_gold_to_platinum"
    elsif user.level_was < User::Levels::GOLD && user.level == User::Levels::GOLD
      attributes[:category] = "account_upgrade_basic_to_gold"
    elsif user.level_was < User::Levels::GOLD && user.level == User::Levels::PLATINUM
      attributes[:category] = "account_upgrade_basic_to_platinum"
    end

    create(attributes)
  end
end
