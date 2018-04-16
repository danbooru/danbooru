class CreateIpBans < ActiveRecord::Migration[4.2]
  def self.up
    create_table :ip_bans do |t|
      t.column :creator_id, :integer, :null => false
      t.column :ip_addr, :inet, :null => false
      t.column :reason, :text, :null => false
      t.timestamps
    end

    add_index :ip_bans, :ip_addr, :unique => true
  end

  def self.down
    drop_table :ip_bans
  end
end
