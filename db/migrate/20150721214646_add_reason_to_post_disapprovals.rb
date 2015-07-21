class AddReasonToPostDisapprovals < ActiveRecord::Migration
  def change
    add_column :post_disapprovals, :reason, :string, :default => "legacy"
  end
end
