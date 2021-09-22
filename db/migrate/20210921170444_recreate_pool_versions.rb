class RecreatePoolVersions < ActiveRecord::Migration[6.1]
  def change
    create_table :pool_versions do |t|
      t.timestamps null: false, index: true
      t.references :pool, null: false, index: true
      t.references :updater, null: false, index: true
      t.inet       :updater_ip_addr, null: false
      t.integer    :version, default: 1, null: false
      t.text       :name, null: false
      t.text       :description, default: "", null: false
      t.string     :category, null: false
      t.boolean    :is_active, default: true, null: false
      t.boolean    :is_deleted, default: false, null: false
      t.boolean    :description_changed, default: false, null: false, index: true
      t.boolean    :name_changed, default: false, null: false, index: true
      t.integer    :post_ids, array: true, default: [], null: false, index: true
      t.integer    :added_post_ids, array: true, default: [], null: false, index: true
      t.integer    :removed_post_ids, array: true, default: [], null: false, index: true
    end
  end
end
