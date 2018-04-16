class AddCustomStyleToUsers < ActiveRecord::Migration[4.2]
  def change
    execute "set statement_timeout = 0"
    add_column :users, :custom_style, :text
  end
end
