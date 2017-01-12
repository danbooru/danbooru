class AddIpAddrIndexesToTables < ActiveRecord::Migration
  def change
    reversible { execute "set statement_timeout = 0" }
    add_index :wiki_page_versions, :updater_ip_addr
    add_index :artist_commentary_versions, :updater_ip_addr
    add_index :artist_versions, :updater_ip_addr
    add_index :comments, :ip_addr
  end
end
