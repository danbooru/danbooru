class AddFingerprintToUserEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :user_events, :fingerprint, :jsonb
    add_column :user_events, :fingerprint_hash, :text
  end
end
