class CreateUserSessions < ActiveRecord::Migration[6.1]
  def change
    create_table :user_sessions do |t|
      t.timestamps null: false, index: true
      t.inet :ip_addr, null: false, index: true
      t.string :session_id, null: false, index: true
      t.string :user_agent
    end
  end
end
