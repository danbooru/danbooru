class CreateUnapprovals < ActiveRecord::Migration
  def self.up
    create_table :unapprovals do |t|
      t.column :post_id, :integer, :null => false
      t.column :reason, :text
      t.column :unapprover_id, :integer, :null => false
      t.column :unapprover_ip_addr, "inet", :null => false
      t.timestamps
    end
    
    add_index :unapprovals, :post_id
  end

  def self.down
    drop_table :unapprovals
  end
end
