class CreateEmailAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :email_addresses do |t|
      t.timestamps

      t.references :user, index: false, null: false
      t.string :address, null: false
      t.string :normalized_address, null: false
      t.boolean :is_verified, default: false, null: false
      t.boolean :is_deliverable, default: true, null: false

      t.index :address
      t.index :normalized_address
      t.index :user_id, unique: true

      t.index :address, name: "index_email_addresses_on_address_trgm", using: :gin, opclass: :gin_trgm_ops
      t.index :normalized_address, name: "index_email_addresses_on_normalized_address_trgm", using: :gin, opclass: :gin_trgm_ops
    end
  end
end
