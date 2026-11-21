# frozen_string_literal: true

class AddExpiresAtToApiKeys < ActiveRecord::Migration[8.1]
  def up
    add_column :api_keys, :expires_at, :datetime

    execute <<~SQL.squish
      UPDATE api_keys
      SET expires_at = now() + interval '1 year'
    SQL

    change_column_null :api_keys, :expires_at, false
    add_index :api_keys, :expires_at
  end

  def down
    remove_column :api_keys, :expires_at
  end
end
