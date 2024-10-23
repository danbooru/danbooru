class AddDurationToNewsUpdates < ActiveRecord::Migration[7.1]
  def change
    add_column :news_updates, :duration, :interval, null: false, default: "2 weeks"
  end
end
