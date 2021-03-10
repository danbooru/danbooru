class ChangeExpiresAtToDurationOnBans < ActiveRecord::Migration[6.1]
  def up
    change_column :bans, :expires_at, :interval, using: "expires_at - created_at"
    rename_column :bans, :expires_at, :duration
  end

  def down
    change_column :bans, :duration, :timestamp, using: "created_at + duration"
    rename_column :bans, :duration, :expires_at
  end
end
