class AddCategoryToModActions < ActiveRecord::Migration
  def change
    ModAction.without_timeout do
      add_column :mod_actions, :category, :integer
    end
  end
end
