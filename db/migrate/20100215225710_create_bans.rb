class CreateBans < ActiveRecord::Migration[4.2]
  def self.up
    create_table :bans do |t|
      t.column :user_id, :integer
      t.column :reason, :text, :null => false
      t.column :banner_id, :integer, :null => false
      t.column :expires_at, :datetime, :null => false
      t.timestamps
    end

    add_index :bans, :user_id
    add_index :bans, :expires_at
    add_index :bans, :banner_id
  end

  def self.down
    drop_table :bans
  end
end
