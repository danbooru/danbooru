class AddThemeToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :theme, :integer, default: 0, null: false
  end
end
