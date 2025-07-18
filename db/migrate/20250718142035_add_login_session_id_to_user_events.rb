class AddLoginSessionIdToUserEvents < ActiveRecord::Migration[8.0]
  def change
    change_table :user_events do |t|
      t.references :login_session, null: true, foreign_key: true
    end
  end
end
