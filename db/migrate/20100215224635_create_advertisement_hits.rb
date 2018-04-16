class CreateAdvertisementHits < ActiveRecord::Migration[4.2]
  def self.up
    create_table :advertisement_hits do |t|
      t.column :advertisement_id, :integer, :null => false
      t.column :ip_addr, "inet", :null => false
      t.timestamps
    end

    add_index :advertisement_hits, :advertisement_id
    add_index :advertisement_hits, :created_at
  end

  def self.down
    drop_table :advertisement_hits
  end
end
