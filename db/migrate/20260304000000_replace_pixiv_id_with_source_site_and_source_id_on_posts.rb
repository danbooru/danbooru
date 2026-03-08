class ReplacePixivIdWithSourceSiteAndSourceIdOnPosts < ActiveRecord::Migration[7.0]
  def up
    add_column :posts, :source_name, :string
    add_column :posts, :source_kind, :string
    add_column :posts, :source_id, :string
    add_column :posts, :source_id_num, :uuid
  end

  def down
    remove_column :posts, :source_name
    remove_column :posts, :source_kind
    remove_column :posts, :source_id
    remove_column :posts, :source_id_num
  end
end
