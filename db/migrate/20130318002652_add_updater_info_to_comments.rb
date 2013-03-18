class AddUpdaterInfoToComments < ActiveRecord::Migration
  def change
    add_column :comments, :updater_id, :integer
    add_column :comments, :updater_ip_addr, "inet"
  end
end
