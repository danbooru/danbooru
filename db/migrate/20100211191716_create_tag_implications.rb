class CreateTagImplications < ActiveRecord::Migration[4.2]
  def self.up
    create_table :tag_implications do |t|
      t.column :antecedent_name, :string, :null => false
      t.column :consequent_name, :string, :null => false
      t.column :descendant_names, :text, :null => false
      t.column :creator_id, :integer, :null => false
      t.column :creator_ip_addr, :inet, :null => false
      t.column :forum_topic_id, :integer
      t.column :status, :text, :null => false, :default => "pending"
      t.timestamps
    end

    add_index :tag_implications, :antecedent_name
    add_index :tag_implications, :consequent_name
  end

  def self.down
    drop_table :tag_implications
  end
end
