class AddIsDeletedToUserFeedback < ActiveRecord::Migration[6.0]
  def change
    add_column :user_feedback, :is_deleted, :boolean, default: false, null: false
  end
end
