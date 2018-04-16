class CreateSuperVoters < ActiveRecord::Migration[4.2]
  def change
    create_table :super_voters do |t|
      t.integer :user_id
      t.timestamps null: false
    end
  end
end
