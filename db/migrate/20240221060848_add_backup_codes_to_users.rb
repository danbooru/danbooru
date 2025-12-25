class AddBackupCodesToUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :backup_codes_secret, :string, null: true
    remove_column :users, :backup_codes_counter, :integer, null: true
    add_column :users, :backup_codes, :integer, array: true
  end
end
