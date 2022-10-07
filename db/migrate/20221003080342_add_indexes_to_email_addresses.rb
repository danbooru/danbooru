class AddIndexesToEmailAddresses < ActiveRecord::Migration[7.0]
  def change
    add_index :email_addresses, :created_at
    add_index :email_addresses, :is_verified, where: "is_verified = FALSE"
    add_index :email_addresses, :is_deliverable, where: "is_deliverable = FALSE"
    add_index :email_addresses, "lower(address)", unique: true, name: "index_email_addresses_on_lower_address_unique"
    add_index :email_addresses, :normalized_address, unique: true, name: "index_email_addresses_on_normalize_address_unique"
  end
end
