class CreateTransactionLogItems < ActiveRecord::Migration[4.2]
  def change
    create_table :transaction_log_items do |t|
      t.string :category
      t.integer :user_id
      t.text :data

      t.timestamps
    end

    add_index :transaction_log_items, :user_id
    add_index :transaction_log_items, :created_at
  end
end
