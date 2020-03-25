class DropEmailsFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :email, :string
  end
end
