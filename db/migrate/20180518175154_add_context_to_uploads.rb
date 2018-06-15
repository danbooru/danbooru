class AddContextToUploads < ActiveRecord::Migration[5.2]
  def change
    add_column :uploads, :context, :text
  end
end
