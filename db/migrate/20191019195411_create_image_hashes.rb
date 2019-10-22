class CreateImageHashes < ActiveRecord::Migration[6.0]
  def change
    enable_extension "cube"

    create_table :image_hashes do |t|
      t.timestamps
      t.column :md5, :string, null: false, unique: true
      t.column :post_md5, :string, null: false

      t.column :phash, :bytea, null: false
      t.column :block_mean_zero_hash, :bytea, null: false
      t.column :marr_hildreth_hash, :bytea, null: false
      t.column :color_moment_hash, :"float8[]", null: false

      t.column :phash_popcount, :"smallint[]", null: false
      t.column :block_mean_zero_hash_popcount, :"smallint[]", null: false
      t.column :marr_hildreth_hash_popcount, :"smallint[]", null: false

      t.index :post_md5
      t.index "cube(phash_popcount)", using: :gist
      t.index "cube(block_mean_zero_hash_popcount)", using: :gist
      t.index "cube(marr_hildreth_hash_popcount)", using: :gist
      t.index "cube(color_moment_hash)", using: :gist
    end
  end
end
