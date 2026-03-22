# frozen_string_literal: true

class PaymentTransaction::Shopify < PaymentTransaction
  def self.enabled?
    false
  end
end
