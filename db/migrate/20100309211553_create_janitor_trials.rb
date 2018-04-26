class CreateJanitorTrials < ActiveRecord::Migration[4.2]
  def self.up
    create_table :janitor_trials do |t|
      t.column :creator_id, :integer, :null => false
      t.column :user_id, :integer, :null => false
      t.column :original_level, :integer, :null => false
      t.timestamps
    end

    add_index :janitor_trials, :user_id
  end

  def self.down
    drop_table :janitor_trials
  end
end
