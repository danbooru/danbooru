class AddTagCountModelToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :tag_count_model, :integer, null: false, default: 0, index: true
  end
end
