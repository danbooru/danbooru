class CreateApiKeys < ActiveRecord::Migration[4.2]
  def change
    create_table :api_keys do |t|
      t.integer :user_id, :null => false
      t.string :key, :null => false

      t.timestamps
    end

    add_index :api_keys, :user_id, :unique => true
    add_index :api_keys, :key, :unique => true
  end
end
