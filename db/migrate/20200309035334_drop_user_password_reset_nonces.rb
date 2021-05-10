require_relative "20110717010705_create_user_password_reset_nonces"

class DropUserPasswordResetNonces < ActiveRecord::Migration[6.0]
  def change
    revert CreateUserPasswordResetNonces
  end
end
