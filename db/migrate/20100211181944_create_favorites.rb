class CreateFavorites < ActiveRecord::Migration
  def self.up
    (0..9).each do |number|
      create_table "favorites_#{number}" do |t|
        t.column :post_id, :integer
        t.column :user_id, :integer
      end
      
      add_index "favorites_#{number}", :post_id
      add_index "favorites_#{number}", :user_id
      add_index "favorites_#{number}", [:post_id, :user_id], :unique => true
    end
  end

  def self.down
    (0..9).each do |number|
      drop_table "favorites_#{number}"
    end
  end
end
