require_relative "20160919234407_create_anti_voters"

class DropAntiVoters < ActiveRecord::Migration[6.0]
  def change
    revert CreateAntiVoters
  end
end
