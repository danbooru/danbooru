class CreatePostReplacements < ActiveRecord::Migration
  def change
    create_table :post_replacements do |t|
    	t.integer :post_id, null: false
    	t.integer :creator_id, null: false
    	t.text :original_url, null: false
    	t.text :replacement_url, null: false
      t.timestamps null: false
    end

    add_index :post_replacements, :post_id
    add_index :post_replacements, :creator_id
  end
end
