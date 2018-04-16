class AddMessageToDisapprovals < ActiveRecord::Migration[4.2]
  def change
    add_column :post_disapprovals, :message, :text
  end
end
