class CreateAmazonBackups < ActiveRecord::Migration[4.2]
  def change
    create_table :amazon_backups do |t|
      t.integer :last_id

      t.timestamps
    end
  end
end
