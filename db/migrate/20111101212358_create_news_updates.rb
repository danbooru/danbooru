class CreateNewsUpdates < ActiveRecord::Migration[4.2]
  def change
    create_table :news_updates do |t|
      t.column :message, :text, :null => false
      t.column :creator_id, :integer, :null => false
      t.column :updater_id, :integer, :null => false
      t.timestamps
    end

    add_index :news_updates, :created_at
  end
end
