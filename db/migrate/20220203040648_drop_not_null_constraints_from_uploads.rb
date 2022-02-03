class DropNotNullConstraintsFromUploads < ActiveRecord::Migration[7.0]
  def change
    change_column_null(:uploads, :rating, true)
    change_column_null(:uploads, :tag_string, true)
  end
end
