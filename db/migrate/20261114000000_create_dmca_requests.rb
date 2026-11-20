class CreateDmcaRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :dmca_requests do |t|
      t.timestamps
      t.string :public_id, null: false
      t.integer :status, null: false, default: 0
      t.string :name
      t.string :email
      t.string :address
      t.text :infringing_urls, null: false
      t.text :original_urls, null: false
      t.string :danbooru_urls, null: false, default: [], array: true
      t.text :proof
      t.string :signature
      t.integer :post_ids, null: false, default: [], array: true

      t.index :public_id, unique: true
      t.index :created_at
      t.index :status
      t.index :post_ids, using: :gin
    end
  end
end
