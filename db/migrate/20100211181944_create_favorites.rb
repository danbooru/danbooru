class CreateFavorites < ActiveRecord::Migration
  TABLE_COUNT = 100
  
  def self.up
    # this is a dummy table and should not be used
    create_table "favorites" do |t|
      t.column :user_id, :integer
      t.column :post_id, :integer
    end

    0.upto(TABLE_COUNT - 1) do |i|
      create_table "favorites_#{i}" do |t|
        t.column :user_id, :integer
        t.column :post_id, :integer
      end
      
      add_index "favorites_#{i}", :user_id
      add_index "favorites_#{i}", :post_id
    end
  end

  def self.down
    drop_table "favorites"
    
    0.upto(TABLE_COUNT - 1) do |i|
      drop_table "favorites_#{i}"
    end
  end
end
