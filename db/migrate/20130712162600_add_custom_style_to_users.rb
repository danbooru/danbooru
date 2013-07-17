class AddCustomStyleToUsers < ActiveRecord::Migration
  def change
    execute "set statement_timeout = 0"
    add_column :users, :custom_style, :text
  end
end
