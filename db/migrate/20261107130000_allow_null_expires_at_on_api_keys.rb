# frozen_string_literal: true

class AllowNullExpiresAtOnApiKeys < ActiveRecord::Migration[8.1]
  def change
    change_column_null :api_keys, :expires_at, true
  end
end
