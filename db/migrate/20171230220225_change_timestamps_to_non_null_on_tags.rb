class ChangeTimestampsToNonNullOnTags < ActiveRecord::Migration[4.2]
  def change
    Post.without_timeout do
      change_column_null :tags, :created_at, false
      change_column_null :tags, :updated_at, false
    end
  end
end
