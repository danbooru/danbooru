class AddReasonToPostDisapprovals < ActiveRecord::Migration[4.2]
  def change
    add_column :post_disapprovals, :reason, :string, :default => "legacy"
  end
end
