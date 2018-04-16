class CreateDmailFilters < ActiveRecord::Migration[4.2]
  def change
    create_table :dmail_filters do |t|
      t.integer :user_id, :null => false
      t.text :words, :null => false

      t.timestamps
    end

    add_index :dmail_filters, :user_id, :unique => true
  end
end
