class ChangeDefaultLevelOnUsers < ActiveRecord::Migration[6.0]
  def change
    change_column_default(:users, :level, from: 0, to: 20)
  end
end
