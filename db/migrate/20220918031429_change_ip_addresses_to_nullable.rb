class ChangeIpAddressesToNullable < ActiveRecord::Migration[7.0]
  def change
    change_column_null :artist_versions, :updater_ip_addr, true
    change_column_null :artist_commentary_versions, :updater_ip_addr, true
    change_column_null :note_versions, :updater_ip_addr, true
    change_column_null :wiki_page_versions, :updater_ip_addr, true
    change_column_null :post_versions, :updater_ip_addr, true
    change_column_null :pool_versions, :updater_ip_addr, true

    change_column_null :comments, :creator_ip_addr, true
    change_column_null :comments, :updater_ip_addr, true
    change_column_null :dmails, :creator_ip_addr, true

    change_column_null :posts, :uploader_ip_addr, true
    change_column_null :uploads, :uploader_ip_addr, true
  end
end
