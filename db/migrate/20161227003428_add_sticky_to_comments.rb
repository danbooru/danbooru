class AddStickyToComments < ActiveRecord::Migration
  def change
    add_column :comments, :is_sticky, :boolean, null: false, default: false
  end
end
