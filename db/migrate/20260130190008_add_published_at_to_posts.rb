class AddPublishedAtToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :published_at, :datetime
    add_index :posts, :published_at
    add_column :post_versions, :published_at, :datetime
    add_column :post_versions, :published_at_changed, :boolean, null: false, default: false
    add_index :post_versions, :published_at_changed
  end
end
