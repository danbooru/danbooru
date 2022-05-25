class CreateUpgradeCodes < ActiveRecord::Migration[7.0]
  def change
    create_table :upgrade_codes do |t|
      t.timestamps
      t.string :code, null: false
      t.integer :status, null: false
      t.integer :creator_id, null: false
      t.integer :redeemer_id
      t.integer :user_upgrade_id

      t.index :code, unique: true
      t.index :status
      t.index :creator_id
      t.index :redeemer_id, where: "redeemer_id IS NOT NULL"
      t.index :user_upgrade_id, where: "user_upgrade_id IS NOT NULL"

      t.foreign_key :users, column: :creator_id
      t.foreign_key :users, column: :redeemer_id
      t.foreign_key :user_upgrades, column: :user_upgrade_id
    end
  end
end
