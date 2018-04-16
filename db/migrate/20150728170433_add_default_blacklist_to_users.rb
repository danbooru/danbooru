class AddDefaultBlacklistToUsers < ActiveRecord::Migration[4.2]
  def self.up
    execute "set statement_timeout = 0"
    blacklist = ["spoilers", "guro", "scat", "furry -rating:s"].join("\n")
    change_column_default(:users, :blacklisted_tags, blacklist)
  end

  def self.down
    execute "set statement_timeout = 0"
    change_column_default(:users, :blacklisted_tags, nil)
  end
end
