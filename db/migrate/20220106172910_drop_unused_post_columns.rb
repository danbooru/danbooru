class DropUnusedPostColumns < ActiveRecord::Migration[6.1]
  def change
    remove_column :posts, :is_note_locked, :boolean, default: false, null: false
    remove_column :posts, :is_rating_locked, :boolean, default: false, null: false
    remove_column :posts, :is_status_locked, :boolean, default: false, null: false
    remove_column :posts, :tag_index, :tsvector
    remove_column :posts, :fav_string, :text, default: "", null: false
    remove_column :posts, :pool_string, :text, default: "", null: false
  end
end
