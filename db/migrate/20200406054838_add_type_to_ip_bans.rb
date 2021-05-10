class AddTypeToIpBans < ActiveRecord::Migration[6.0]
  def change
    add_column :ip_bans, :is_deleted, :boolean, default: false, null: false
    add_column :ip_bans, :category, :integer, default: 0, null: false
    add_column :ip_bans, :hit_count, :integer, default: 0, null: false
    add_column :ip_bans, :last_hit_at, :datetime

    add_index :ip_bans, :is_deleted
    add_index :ip_bans, :category
  end
end
