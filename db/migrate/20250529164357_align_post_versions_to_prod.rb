class AlignPostVersionsToProd < ActiveRecord::Migration[7.1]
  def up
    change_column :post_versions, :id, :integer

    remove_column :post_versions, :created_at

    change_column :post_versions, :updated_at, :timestamp, null: false
    change_column :post_versions, :post_id, :integer
    change_column :post_versions, :updater_id, :integer, null: true

    change_column_null :post_versions, :rating, true
    change_column_default :post_versions, :rating, from: '', to: nil

    change_column_null :post_versions, :source, true
    change_column_default :post_versions, :source, from: '', to: nil

    change_column_null :post_versions, :tags, false
    change_column_default :post_versions, :tags, from: '', to: nil
  end

  def down
    change_column :post_versions, :id, :bigint

    add_column :post_versions, :created_at, :timestamp, null: false, default: -> { 'CURRENT_TIMESTAMP' }

    change_column :post_versions, :updated_at, :timestamp, null: false
    change_column :post_versions, :post_id, :bigint
    change_column :post_versions, :updater_id, :bigint, null: false

    change_column_null :post_versions, :rating, false
    change_column_default :post_versions, :rating, from: nil, to: ''

    change_column_null :post_versions, :source, false
    change_column_default :post_versions, :source, from: nil, to: ''

    change_column_null :post_versions, :tags, false
    change_column_default :post_versions, :tags, from: nil, to: ''
  end
end
