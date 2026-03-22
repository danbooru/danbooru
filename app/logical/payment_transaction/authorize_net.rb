# frozen_string_literal: true

# https://sandbox.authorize.net/
# https://developer.authorize.net/hello_world.html
# https://developer.authorize.net/api/reference/index.html
# https://developer.authorize.net/api/reference/features/accept_hosted.html
# https://developer.authorize.net/hello_world/testing_guide.html
class PaymentTransaction::AuthorizeNet < PaymentTransaction
  def self.enabled?
    false
  end
end
