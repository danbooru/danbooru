class AddUniqueNameConstraintToUsers < ActiveRecord::Migration
  def up
  	ActiveRecord::Base.without_timeout do
	  	remove_index :users, :name
  		execute "create unique index index_users_on_name on users(lower(name))"
  	end
  end
end
