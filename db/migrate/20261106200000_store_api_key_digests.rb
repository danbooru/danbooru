# frozen_string_literal: true

class StoreApiKeyDigests < ActiveRecord::Migration[8.1]
  def up
    add_column :api_keys, :key_digest, :string

    execute <<~SQL.squish
      UPDATE api_keys
      SET key_digest = encode(digest(key, 'sha256'), 'hex')
    SQL

    change_column_null :api_keys, :key_digest, false
    add_index :api_keys, :key_digest, unique: true
    remove_column :api_keys, :key
  end

  def down
    add_column :api_keys, :key, :string

    execute <<~SQL.squish
      UPDATE api_keys
      SET key = encode(gen_random_bytes(24), 'hex')
    SQL

    change_column_null :api_keys, :key, false
    add_index :api_keys, :key, unique: true
    remove_column :api_keys, :key_digest
  end
end
