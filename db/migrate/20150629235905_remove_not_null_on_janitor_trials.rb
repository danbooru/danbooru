class RemoveNotNullOnJanitorTrials < ActiveRecord::Migration
  def change
    change_column :janitor_trials, :original_level, :integer, :null => true
  end
end
