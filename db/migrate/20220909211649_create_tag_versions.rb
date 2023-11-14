class CreateTagVersions < ActiveRecord::Migration[7.0]
  def change
    create_table :tag_versions do |t|
      t.timestamps
      t.references :tag, null: false, foreign_key: { to_table: :tags }
      t.references :updater, null: true, foreign_key: { to_table: :users }
      t.references :previous_version, null: true, foreign_key: { to_table: :tag_versions }

      t.column :version, :integer, null: false
      t.column :name, :string, null: false
      t.column :category, :integer, null: false
      t.column :is_deprecated, :boolean, null: false

      t.index :name, opclass: :text_pattern_ops
      t.index :name, name: "index_tag_versions_on_name_trgm", using: :gin, opclass: :gin_trgm_ops
      t.index :version
      t.index :category
      t.index :is_deprecated

      t.index [:tag_id, :previous_version_id], unique: true
    end
  end
end
