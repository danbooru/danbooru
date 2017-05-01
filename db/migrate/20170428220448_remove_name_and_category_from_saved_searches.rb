class RemoveNameAndCategoryFromSavedSearches < ActiveRecord::Migration
  def change
    SavedSearch.without_timeout do
      remove_column :saved_searches, :name, :text
      remove_column :saved_searches, :category, :text
    end
  end
end
