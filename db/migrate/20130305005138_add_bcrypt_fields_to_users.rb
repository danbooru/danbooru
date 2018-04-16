class AddBcryptFieldsToUsers < ActiveRecord::Migration[4.2]
  def change
    execute "set statement_timeout = 0"

    add_column :users, :bcrypt_password_hash, :text
  end
end
