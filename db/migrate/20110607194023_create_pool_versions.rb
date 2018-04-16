class CreatePoolVersions < ActiveRecord::Migration[4.2]
  def up
    create_table :pool_versions do |t|
      t.column :pool_id, :integer
      t.column :post_ids, :text, :null => false, :default => ""
      t.column :updater_id, :integer, :null => false
      t.column :updater_ip_addr, "inet", :null => false
      t.timestamps
    end

    add_index :pool_versions, :pool_id
    add_index :pool_versions, :updater_id
    add_index :pool_versions, :updater_ip_addr
  end

  def down
    drop_table :pool_versions
  end
end
