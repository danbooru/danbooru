class RenameStripeIdToTransactionIdOnUserUpgrades < ActiveRecord::Migration[7.0]
  def change
    add_column :user_upgrades, :payment_processor, :integer, null: false, default: 0
    rename_column :user_upgrades, :stripe_id, :transaction_id
    add_index :user_upgrades, :payment_processor
  end
end
