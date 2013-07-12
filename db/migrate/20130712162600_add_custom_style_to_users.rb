class AddCustomStyleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :custom_style, :text
  end
end
