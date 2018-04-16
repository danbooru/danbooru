class DropTransactionLogItems < ActiveRecord::Migration[4.2]
  def up
  	drop_table :transaction_log_items
  end
end
