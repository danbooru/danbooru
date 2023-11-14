class DropUpdaterIpAddrsFromTables < ActiveRecord::Migration[7.0]
  def change
    remove_index :artist_commentary_versions, :updater_ip_addr
    remove_index :artist_versions, :updater_ip_addr
    remove_index :note_versions, :updater_ip_addr
    remove_index :wiki_page_versions, :updater_ip_addr

    remove_index :comments, :creator_ip_addr
    remove_index :dmails, :creator_ip_addr
    remove_index :posts, :uploader_ip_addr
    remove_index :uploads, :uploader_ip_addr

    remove_column :artist_commentary_versions, :updater_ip_addr, :inet
    remove_column :artist_versions, :updater_ip_addr, :inet
    remove_column :note_versions, :updater_ip_addr, :inet
    remove_column :pool_versions, :updater_ip_addr, :inet
    remove_column :post_versions, :updater_ip_addr, :inet
    remove_column :wiki_page_versions, :updater_ip_addr, :inet

    remove_column :comments, :creator_ip_addr, :inet
    remove_column :comments, :updater_ip_addr, :inet
    remove_column :dmails, :creator_ip_addr, :inet
    remove_column :posts, :uploader_ip_addr, :inet
    remove_column :uploads, :uploader_ip_addr, :inet
  end
end
