class CreateSavedSearches < ActiveRecord::Migration[4.2]
  def change
    create_table :saved_searches do |t|
      t.integer :user_id
      t.text :tag_query
      t.text :name
      t.string :category

      t.timestamps
    end

    add_index :saved_searches, :user_id
    add_index :saved_searches, :tag_query
    add_index :saved_searches, :category
  end
end
