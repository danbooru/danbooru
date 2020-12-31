StripeMock.webhook_fixture_path = "test/fixtures/stripe-webhooks"

module StripeTestHelper
  def mock_stripe!
    setup do
      StripeMock.start unless UserUpgrade.enabled?
    end

    teardown do
      StripeMock.stop unless UserUpgrade.enabled?
    end
  end
end
