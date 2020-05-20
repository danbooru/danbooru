class CreateLinkedAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :linked_accounts do |t|
      t.timestamps
      t.timestamp :account_data_updated_at, null: false
      t.timestamp :api_key_updated_at, null: false
      t.integer :user_id, null: false
      t.integer :site, null: false
      t.boolean :is_public, default: true, null: false
      t.string :account_id, null: false
      t.jsonb :account_data, null: false
      t.jsonb :api_key

      t.index :account_data_updated_at
      t.index :api_key_updated_at
      t.index :user_id
      t.index :site
      t.index :is_public
      t.index :account_id
      t.index :account_data, using: :gin
      t.index :api_key, using: :gin
      t.index [:site, :user_id], unique: true
      t.index [:site, :account_id], unique: true
    end
  end
end
