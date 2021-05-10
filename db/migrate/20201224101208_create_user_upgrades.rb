class CreateUserUpgrades < ActiveRecord::Migration[6.1]
  def change
    create_table :user_upgrades do |t|
      t.timestamps

      t.references :recipient, index: true, null: false
      t.references :purchaser, index: true, null: false
      t.integer :upgrade_type, index: true, null: false
      t.integer :status, index: true, null: false
      t.string :stripe_id, index: true, null: true
    end

    # Reserve ID space for backfilling old upgrades.
    reversible do |dir|
      dir.up do
        execute "SELECT setval('user_upgrades_id_seq', 25000, false)"
      end
    end
  end
end
