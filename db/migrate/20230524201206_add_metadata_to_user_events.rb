class AddMetadataToUserEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :user_events, :ip_addr, :inet, null: true
    add_column :user_events, :session_id, :uuid, null: true
    add_column :user_events, :user_agent, :string, null: true
    add_column :user_events, :metadata, :jsonb, null: true

    add_index :user_events, :ip_addr
    add_index :user_events, :session_id
    add_index :user_events, :user_agent, using: :gin, opclass: :gin_trgm_ops
    add_index :user_events, :metadata, using: :gin
  end
end
