class ChangeLoginSessionIdToUuidOnUserEvents < ActiveRecord::Migration[8.0]
  def up
    change_table :user_events do |t|
      t.remove :login_session_id
      t.references :login_session, type: :uuid, null: true, foreign_key: { primary_key: :login_id }
    end
  end

  def down
    change_table :user_events do |t|
      t.remove :login_session_id
      t.references :login_session, type: :bigint, null: true, foreign_key: { primary_key: :id }
    end
  end
end
