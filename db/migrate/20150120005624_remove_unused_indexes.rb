class RemoveUnusedIndexes < ActiveRecord::Migration[4.2]
  def change
    execute "set statement_timeout = 0"
    begin
      remove_index :posts, :source
      remove_index :posts, :uploader_ip_addr
    rescue ArgumentError
    end
  end
end
