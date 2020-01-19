require_relative "20141120045943_create_dmail_filters"

class DropDmailFilters < ActiveRecord::Migration[6.0]
  def change
    revert CreateDmailFilters
  end
end
