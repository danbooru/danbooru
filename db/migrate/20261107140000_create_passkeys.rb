# frozen_string_literal: true

class CreatePasskeys < ActiveRecord::Migration[8.1]
  def change
    create_table :passkeys do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.string :external_id, null: false
      t.string :public_key, null: false
      t.string :nickname
      t.bigint :sign_count, null: false, default: 0
      t.datetime :last_used_at
      t.timestamps
    end

    add_index :passkeys, :external_id, unique: true
  end
end
