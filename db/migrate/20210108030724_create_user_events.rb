class CreateUserEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :user_events do |t|
      t.timestamps null: false, index: true
      t.references :user, null: false, index: true
      t.references :user_session, null: false, index: true
      t.integer :category, null: false, index: true
    end
  end
end
