class CreatePostHistories < ActiveRecord::Migration
  def self.up
    create_table :post_histories do |t|
      t.timestamps
      
      t.column :post_id, :integer, :null => false
      t.column :revisions, :text, :null => false
    end
    
    add_index :post_histories, :post_id
  end

  def self.down
    drop_table :post_histories
  end
end
