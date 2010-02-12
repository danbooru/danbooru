class CreateTagImplications < ActiveRecord::Migration
  def self.up
    create_table :tag_implications do |t|
      t.column :antecedent_name, :string, :null => false
      t.column :consequent_name, :string, :null => false
      t.column :descendant_names, :text, :null => false
      t.column :creator_id, :integer, :null => false
      t.column :request_ids, :string
      t.timestamps
    end
    
    add_index :tag_implications, :antecedent_name
    add_index :tag_implications, :consequent_name
  end

  def self.down
    drop_table :tag_implications
  end
end
