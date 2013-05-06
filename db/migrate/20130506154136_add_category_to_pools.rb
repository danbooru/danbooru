class AddCategoryToPools < ActiveRecord::Migration
  def change
    execute("set statement_timeout = 0")
    add_column :pools, :category, :string, :null => false, :default => "series"
  end
end
