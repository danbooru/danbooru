require_relative "20100309211553_create_janitor_trials"

class DropJanitorTrials < ActiveRecord::Migration[6.0]
  def change
    revert CreateJanitorTrials
  end
end
