require 'test_helper'

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    StripeMock.start
  end

  teardown do
    StripeMock.stop
  end

  def post_webhook(*args, payment_status: "paid", **metadata)
    event = StripeMock.mock_webhook_event(*args, payment_status: payment_status, metadata: metadata)
    signature = generate_stripe_signature(event)
    headers = { "Stripe-Signature": signature }

    post receive_webhooks_path(source: "stripe"), headers: headers, params: event, as: :json
  end

  # https://github.com/stripe-ruby-mock/stripe-ruby-mock/issues/467#issuecomment-634674913
  # https://stripe.com/docs/webhooks/signatures
  def generate_stripe_signature(event)
    time = Time.now
    secret = UserUpgrade.stripe_webhook_secret
    signature = Stripe::Webhook::Signature.compute_signature(time, event.to_json, secret)
    Stripe::Webhook::Signature.generate_header(time, signature, scheme: Stripe::Webhook::Signature::EXPECTED_SCHEME)
  end

  context "The webhooks controller" do
    context "receive action" do
      context "for a request from an unrecognized source" do
        should "fail" do
          post receive_webhooks_path(source: "blah")
          assert_response 400
        end
      end

      context "for a Stripe webhook" do
        context "with a missing signature" do
          should "fail" do
            event = StripeMock.mock_webhook_event("payment_intent.created")
            post receive_webhooks_path(source: "stripe"), params: event, as: :json

            assert_response 400
          end
        end

        context "with an invalid signature" do
          should "fail" do
            event = StripeMock.mock_webhook_event("payment_intent.created")
            headers = { "Stripe-Signature": "blah" }
            post receive_webhooks_path(source: "stripe"), headers: headers, params: event, as: :json

            assert_response 400
          end
        end

        context "for a payment_intent.created event" do
          should "work" do
            post_webhook("payment_intent.created")

            assert_response 200
          end
        end

        context "for a checkout.session.completed event" do
          context "for completed event with an unpaid payment status" do
            should "not upgrade the user" do
              @user_upgrade = create(:self_gold_upgrade)
              post_webhook("checkout.session.completed", { user_upgrade_id: @user_upgrade.id, payment_status: "unpaid" })

              assert_response 200
              assert_equal("processing", @user_upgrade.reload.status)
              assert_equal(User::Levels::MEMBER, @user_upgrade.recipient.reload.level)
            end
          end

          context "for a self upgrade" do
            context "to Gold" do
              should "upgrade the user" do
                @user_upgrade = create(:self_gold_upgrade)
                post_webhook("checkout.session.completed", { user_upgrade_id: @user_upgrade.id })

                assert_response 200
                assert_equal("complete", @user_upgrade.reload.status)
                assert_equal(User::Levels::GOLD, @user_upgrade.recipient.reload.level)
              end
            end

            context "to Platinum" do
              should "upgrade the user" do
                @user_upgrade = create(:self_platinum_upgrade)
                post_webhook("checkout.session.completed", { user_upgrade_id: @user_upgrade.id })

                assert_response 200
                assert_equal("complete", @user_upgrade.reload.status)
                assert_equal(User::Levels::PLATINUM, @user_upgrade.recipient.reload.level)
              end
            end

            context "from Gold to Platinum" do
              should "upgrade the user" do
                @user_upgrade = create(:self_gold_to_platinum_upgrade)
                post_webhook("checkout.session.completed", { user_upgrade_id: @user_upgrade.id })

                assert_response 200
                assert_equal("complete", @user_upgrade.reload.status)
                assert_equal(User::Levels::PLATINUM, @user_upgrade.recipient.reload.level)
              end
            end
          end

          context "for a gifted upgrade" do
            context "to Gold" do
              should "upgrade the user" do
                @user_upgrade = create(:gift_gold_upgrade)
                post_webhook("checkout.session.completed", { user_upgrade_id: @user_upgrade.id })

                assert_response 200
                assert_equal("complete", @user_upgrade.reload.status)
                assert_equal(User::Levels::GOLD, @user_upgrade.recipient.reload.level)
              end
            end

            context "to Platinum" do
              should "upgrade the user" do
                @user_upgrade = create(:gift_platinum_upgrade)
                post_webhook("checkout.session.completed", { user_upgrade_id: @user_upgrade.id })

                assert_response 200
                assert_equal("complete", @user_upgrade.reload.status)
                assert_equal(User::Levels::PLATINUM, @user_upgrade.recipient.reload.level)
              end
            end

            context "from Gold to Platinum" do
              should "upgrade the user" do
                @user_upgrade = create(:gift_gold_to_platinum_upgrade)
                post_webhook("checkout.session.completed", { user_upgrade_id: @user_upgrade.id })

                assert_response 200
                assert_equal("complete", @user_upgrade.reload.status)
                assert_equal(User::Levels::PLATINUM, @user_upgrade.recipient.reload.level)
              end
            end
          end
        end
      end
    end
  end
end
