class AddDmailCountToUsers < ActiveRecord::Migration[5.1]
  def change
    ApplicationRecord.without_timeout do
      add_column :users, :unread_dmail_count, :integer, default: 0, null: false
      execute "update users set unread_dmail_count = (select count(*) from dmails where dmails.owner_id = users.id and dmails.is_read = false)"
    end
  end
end
