require_relative "20170106012138_create_token_buckets"

class ReplaceTokenBucketsWithRateLimits < ActiveRecord::Migration[6.1]
  def change
    revert CreateTokenBuckets

    create_table :rate_limits do |t|
      t.timestamps null: false
      t.boolean :limited, null: false, default: false
      t.float :points, null: false
      t.string :action, null: false
      t.string :key, null: false

      t.index [:key, :action], unique: true
    end

    reversible do |dir|
      dir.up do
        execute "ALTER TABLE rate_limits SET UNLOGGED"
        execute "ALTER TABLE rate_limits SET (fillfactor = 50)"
      end
    end
  end
end
