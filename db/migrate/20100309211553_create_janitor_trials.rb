class CreateJanitorTrials < ActiveRecord::Migration
  def self.up
    create_table :janitor_trials do |t|
      t.column :user_id, :integer, :null => false
      t.column :promoted_at, :datetime
      t.column :original_level, :integer, :null => false
      t.timestamps
    end
    
    add_inex :janitor_trials, :user_id
  end

  def self.down
    drop_table :janitor_trials
  end
end
