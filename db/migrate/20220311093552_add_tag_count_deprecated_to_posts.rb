class AddTagCountDeprecatedToPosts < ActiveRecord::Migration[7.0]
  def change
    Post.without_timeout do
      add_column :posts, :tag_count_deprecated, :integer, default: 0, null: false
    end
  end
end
