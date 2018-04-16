class RemoveNotNullOnJanitorTrials < ActiveRecord::Migration[4.2]
  def change
    change_column :janitor_trials, :original_level, :integer, :null => true
  end
end
