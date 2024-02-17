class AddTOTPSecretToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :totp_secret, :string, null: true
    add_column :users, :backup_codes_secret, :string, null: true
    add_column :users, :backup_codes_counter, :integer, null: true
  end
end
