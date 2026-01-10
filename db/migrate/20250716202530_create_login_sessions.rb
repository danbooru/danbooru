class CreateLoginSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :login_sessions do |t|
      t.timestamps null: false
      t.references :user, null: false, foreign_key: true
      t.column :login_id, :uuid, null: false, index: { unique: true }
      t.column :session_id, :uuid, null: false, index: true
      t.column :status, :integer, null: false, index: true
      t.column :last_seen_at, :datetime, null: true

      t.index [:created_at, :id]
      t.index [:updated_at, :id]
      t.index [:last_seen_at, :id]
    end

    reversible do |dir|
      dir.up do
        execute "ALTER SEQUENCE login_sessions_id_seq START WITH 10000000"
        execute "ALTER SEQUENCE login_sessions_id_seq RESTART"
      end
    end
  end
end
