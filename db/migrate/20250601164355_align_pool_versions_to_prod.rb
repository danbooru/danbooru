class AlignPoolVersionsToProd < ActiveRecord::Migration[7.1]
  def up
    change_column :pool_versions, :id, :integer
    change_column_null :pool_versions, :created_at, true
    change_column_null :pool_versions, :updated_at, true
    change_column :pool_versions, :pool_id, :integer
    change_column :pool_versions, :updater_id, :integer, null: true

    change_column_null :pool_versions, :name, true
    change_column_default :pool_versions, :name, from: '', to: nil

    change_column_null :pool_versions, :description, true
    change_column_default :pool_versions, :description, from: '', to: nil

    change_column_null :pool_versions, :category, true
    change_column_default :pool_versions, :category, from: '', to: nil

    add_column :pool_versions, :boolean, :boolean, default: false, null: false

  end

  def down
    change_column :pool_versions, :id, :bigint
    change_column_null :pool_versions, :created_at, false
    change_column_null :pool_versions, :updated_at, false
    change_column :pool_versions, :pool_id, :bigint
    change_column :pool_versions, :updater_id, :bigint, null: false

    change_column_null :pool_versions, :name, false
    change_column_default :pool_versions, :name, from: nil, to: ''

    change_column_null :pool_versions, :description, false
    change_column_default :pool_versions, :description, from: nil, to: ''

    change_column_null :pool_versions, :category, false
    change_column_default :pool_versions, :category, from: nil, to: ''

    remove_column :pool_versions, :boolean
  end
end
