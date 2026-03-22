# frozen_string_literal: true

class PaymentTransaction::Stripe < PaymentTransaction
  def self.enabled?
    false
  end
end
