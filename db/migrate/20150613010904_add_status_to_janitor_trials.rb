class AddStatusToJanitorTrials < ActiveRecord::Migration
  def change
    add_column :janitor_trials, :status, :string, :null => false, :default => "active"
  end
end
