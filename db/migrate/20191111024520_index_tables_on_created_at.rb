class IndexTablesOnCreatedAt < ActiveRecord::Migration[6.0]
  def change
    add_index :artist_commentary_versions, :created_at
    add_index :users, :created_at
    add_index :comments, :created_at
    add_index :posts, :uploader_ip_addr
  end
end
