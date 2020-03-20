class EmailAddressPolicy < ApplicationPolicy
  def show?
    record.user_id == user.id
  end

  def update?
    # XXX here record is a user, not the email address.
    record.id == user.id
  end

  def verify?
    record.valid_key?(request.params[:email_verification_key])
  end
end
