class AddSiteCredentials < ActiveRecord::Migration[7.1]
  def change
    create_table :site_credentials do |t|
      t.timestamps null: false
      t.integer :site, null: false, index: true
      t.references :creator, null: false, foreign_key: { to_table: :users }, index: true
      t.boolean :is_enabled, default: true, null: false, index: true
      t.boolean :is_public, default: true, null: false, index: true
      t.integer :status, default: 0, null: false, index: true
      t.integer :usage_count, default: 0, null: false, index: true
      t.integer :error_count, default: 0, null: false, index: true
      t.datetime :last_used_at, index: true
      t.datetime :last_error_at, index: true
      t.jsonb :credential, default: {}, null: false
      t.jsonb :metadata, default: {}, null: false

      t.index :credential, using: :gin
      t.index :metadata, using: :gin
    end
  end
end
