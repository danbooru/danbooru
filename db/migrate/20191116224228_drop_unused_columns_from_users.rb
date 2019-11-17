class DropUnusedColumnsFromUsers < ActiveRecord::Migration[6.0]
  def change
    execute "set statement_timeout = 0"

    remove_column :users, :base_upload_limit, :integer, null: false, default: 10
    remove_column :users, :recent_tags, :string
    remove_column :users, :email_verification_key, :string
    remove_column :users, :password_hash, :string, null: false
  end
end
