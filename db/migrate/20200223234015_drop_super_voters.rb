require_relative "20160222211328_create_super_voters"

class DropSuperVoters < ActiveRecord::Migration[6.0]
  def change
    revert CreateSuperVoters
  end
end
