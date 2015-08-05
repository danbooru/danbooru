class AddMessageToDisapprovals < ActiveRecord::Migration
  def change
    add_column :post_disapprovals, :message, :text
  end
end
