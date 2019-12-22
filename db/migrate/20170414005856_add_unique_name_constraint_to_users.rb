class AddUniqueNameConstraintToUsers < ActiveRecord::Migration[4.2]
  def up
    User.without_timeout do
      remove_index :users, name: "index_users_on_name"
      execute "create unique index index_users_on_name on users(lower(name))"
    end
  end
end
