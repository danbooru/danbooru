class RecreatePostVersions < ActiveRecord::Migration[6.1]
  def change
    create_table :post_versions do |t|
      t.timestamps null: false, index: true
      t.references :post, null: false, index: true
      t.references :updater, null: false, index: true
      t.inet       :updater_ip_addr, null: false
      t.integer    :version, null: false, default: 1, index: true
      t.boolean    :parent_changed, null: false, default: false, index: true
      t.boolean    :rating_changed, null: false, default: false, index: true
      t.boolean    :source_changed, null: false, default: false, index: true
      t.integer    :parent_id
      t.string     :rating, limit: 1, null: false
      t.text       :source, null: false, default: ""
      t.text       :tags, null: false, default: ""
      t.text       :added_tags, null: false, array: true, default: [], index: true
      t.text       :removed_tags, null: false, array: true, default: [], index: true
    end
  end
end
