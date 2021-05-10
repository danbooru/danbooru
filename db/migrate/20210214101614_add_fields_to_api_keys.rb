class AddFieldsToApiKeys < ActiveRecord::Migration[6.1]
  def change
    change_table :api_keys do |t|
      t.string :name, null: false, default: ""
      t.string :permissions, array: true, null: false, default: "{}"
      t.inet :permitted_ip_addresses, array: true, null: false, default: "{}"
      t.integer :uses, null: false, default: 0
      t.timestamp :last_used_at, null: true
      t.inet :last_ip_address, null: true
    end
  end
end
