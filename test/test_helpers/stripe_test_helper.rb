StripeMock.webhook_fixture_path = "test/fixtures/stripe-webhooks"

module StripeTestHelper
  def mock_stripe!
    setup do
      StripeMock.start
    end

    teardown do
      StripeMock.stop
    end
  end
end
