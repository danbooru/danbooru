class SetUserSessionIdToNullableOnUserEvents < ActiveRecord::Migration[8.0]
  def change
    change_table :user_events do |t|
      t.change_null :user_session_id, true
    end
  end
end
