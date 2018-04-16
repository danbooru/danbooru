class AddUpdaterInfoToComments < ActiveRecord::Migration[4.2]
  def change
    add_column :comments, :updater_id, :integer
    add_column :comments, :updater_ip_addr, "inet"
  end
end
