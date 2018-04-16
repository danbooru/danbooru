class AddStatusToJanitorTrials < ActiveRecord::Migration[4.2]
  def change
    add_column :janitor_trials, :status, :string, :null => false, :default => "active"
  end
end
