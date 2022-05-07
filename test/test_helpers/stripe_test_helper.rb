StripeMock.webhook_fixture_path = "test/fixtures/stripe-webhooks"

module StripeTestHelper
  def mock_stripe!
    setup do
      StripeMock.start unless PaymentTransaction::Stripe.enabled?
    end

    teardown do
      StripeMock.stop unless PaymentTransaction::Stripe.enabled?
    end
  end
end
