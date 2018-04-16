class AddPerPageToUsers < ActiveRecord::Migration[4.2]
  def change
    execute("set statement_timeout = 0")
    add_column :users, :per_page, :integer, :null => false, :default => 20
  end
end
