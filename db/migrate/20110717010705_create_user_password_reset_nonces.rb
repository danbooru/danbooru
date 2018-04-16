class CreateUserPasswordResetNonces < ActiveRecord::Migration[4.2]
  def change
    create_table :user_password_reset_nonces do |t|
      t.column :key, :string, :null => false
      t.column :email, :string, :null => false
      t.timestamps
    end
  end
end
