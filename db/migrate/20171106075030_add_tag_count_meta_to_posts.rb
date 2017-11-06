class AddTagCountMetaToPosts < ActiveRecord::Migration
  def change
    Post.without_timeout do
      add_column :posts, :tag_count_meta, :integer, default: 0, null: false
    end
  end
end
