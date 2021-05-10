class AddStatusToPostAppealsAndFlags < ActiveRecord::Migration[6.0]
  def change
    add_column :post_appeals, :status, :integer, default: 0, null: false
    add_index :post_appeals, :status

    add_column :post_flags, :status, :integer, default: 0, null: false
    add_index :post_flags, :status
  end
end
