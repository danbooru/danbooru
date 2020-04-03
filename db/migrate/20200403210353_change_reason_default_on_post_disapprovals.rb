class ChangeReasonDefaultOnPostDisapprovals < ActiveRecord::Migration[6.0]
  def change
    change_column_null :post_disapprovals, :reason, false
    change_column_default :post_disapprovals, :reason, from: "legacy", to: nil
  end
end
