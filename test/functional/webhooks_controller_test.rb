require 'test_helper'

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  mock_stripe!

  def post_webhook(*args, **metadata)
    event = StripeMock.mock_webhook_event(*args, metadata: metadata)
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
          context "for a self upgrade" do
            context "of a Member to Gold" do
              should "upgrade the user" do
                @user = create(:member_user)

                post_webhook("checkout.session.completed", {
                  recipient_id: @user.id,
                  purchaser_id: @user.id,
                  upgrade_type: "gold_upgrade",
                  level: User::Levels::GOLD,
                })

                assert_response 200
                assert_equal(User::Levels::GOLD, @user.reload.level)
              end
            end

            context "of a Member to Platinum" do
              should "upgrade the user" do
                @user = create(:member_user)

                post_webhook("checkout.session.completed", {
                  recipient_id: @user.id,
                  purchaser_id: @user.id,
                  upgrade_type: "platinum_upgrade",
                  level: User::Levels::PLATINUM,
                })

                assert_response 200
                assert_equal(User::Levels::PLATINUM, @user.reload.level)
              end
            end

            context "of a Gold user to Platinum" do
              should "upgrade the user" do
                @user = create(:gold_user)

                post_webhook("checkout.session.completed", {
                  recipient_id: @user.id,
                  purchaser_id: @user.id,
                  upgrade_type: "gold_to_platinum_upgrade",
                  level: User::Levels::PLATINUM,
                })

                assert_response 200
                assert_equal(User::Levels::PLATINUM, @user.reload.level)
              end
            end
          end

          context "for a gifted upgrade" do
            context "of a Member to Gold" do
              should "upgrade the user" do
                @recipient = create(:member_user)
                @purchaser = create(:member_user)

                post_webhook("checkout.session.completed", {
                  recipient_id: @recipient.id,
                  purchaser_id: @purchaser.id,
                  upgrade_type: "gold_upgrade",
                  level: User::Levels::GOLD,
                })

                assert_response 200
                assert_equal(User::Levels::GOLD, @recipient.reload.level)
              end
            end

            context "of a Member to Platinum" do
              should "upgrade the user" do
                @recipient = create(:member_user)
                @purchaser = create(:member_user)

                post_webhook("checkout.session.completed", {
                  recipient_id: @recipient.id,
                  purchaser_id: @purchaser.id,
                  upgrade_type: "platinum_upgrade",
                  level: User::Levels::PLATINUM,
                })

                assert_response 200
                assert_equal(User::Levels::PLATINUM, @recipient.reload.level)
              end
            end

            context "of a Gold user to Platinum" do
              should "upgrade the user" do
                @recipient = create(:gold_user)
                @purchaser = create(:member_user)

                post_webhook("checkout.session.completed", {
                  recipient_id: @recipient.id,
                  purchaser_id: @purchaser.id,
                  upgrade_type: "gold_to_platinum_upgrade",
                  level: User::Levels::PLATINUM,
                })

                assert_response 200
                assert_equal(User::Levels::PLATINUM, @recipient.reload.level)
              end
            end
          end
        end
      end
    end
  end
end
