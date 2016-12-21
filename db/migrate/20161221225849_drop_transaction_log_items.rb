class DropTransactionLogItems < ActiveRecord::Migration
  def up
  	drop_table :transaction_log_items
  end
end
