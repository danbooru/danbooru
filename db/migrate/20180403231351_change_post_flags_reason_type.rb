class ChangePostFlagsReasonType < ActiveRecord::Migration[4.2]
  def change
    change_column :post_flags, :reason, :text
    change_column :post_appeals, :reason, :text
  end
end
