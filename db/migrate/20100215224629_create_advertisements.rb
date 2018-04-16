class CreateAdvertisements < ActiveRecord::Migration[4.2]
  def self.up
    create_table :advertisements do |t|
      t.column :referral_url, :text, :null => false
      t.column :ad_type, :string, :null => false
      t.column :status, :string, :null => false
      t.column :hit_count, :integer, :null => false, :default => 0
      t.column :width, :integer, :null => false
      t.column :height, :integer, :null => false
      t.column :file_name, :string, :null => false
      t.column :is_work_safe, :boolean, :null => false, :default => false
      t.timestamps
    end

    add_index :advertisements, :ad_type
  end

  def self.down
    drop_table :advertisements
  end
end
