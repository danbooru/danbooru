require 'test_helper'

class UserUpgradeTest < ActiveSupport::TestCase
  context "UserUpgrade:" do
    context "the #process_upgrade! method" do
      context "for a self upgrade" do
        context "to Gold" do
          setup do
            @user_upgrade = create(:self_gold_upgrade)
          end

          should "update the user's level if the payment status is paid" do
            @user_upgrade.process_upgrade!("paid")

            assert_equal(User::Levels::GOLD, @user_upgrade.recipient.level)
            assert_equal("complete", @user_upgrade.status)
          end

          should "not update the user's level if the payment is unpaid" do
            @user_upgrade.process_upgrade!("unpaid")

            assert_equal(User::Levels::MEMBER, @user_upgrade.recipient.level)
            assert_equal("processing", @user_upgrade.status)
          end

          should "not update the user's level if the upgrade status is complete" do
            @user_upgrade.update!(status: "complete")
            @user_upgrade.process_upgrade!("paid")

            assert_equal(User::Levels::MEMBER, @user_upgrade.recipient.level)
            assert_equal("complete", @user_upgrade.status)
          end

          should "log an account upgrade modaction" do
            assert_difference("ModAction.user_account_upgrade.count") do
              @user_upgrade.process_upgrade!("paid")
            end
          end

          should "send the recipient a dmail" do
            assert_difference("@user_upgrade.recipient.dmails.received.count") do
              @user_upgrade.process_upgrade!("paid")
            end
          end
        end
      end
    end

    context "the #create_checkout! method" do
      context "for a gifted upgrade" do
        context "to Gold" do
          should "prefill the Stripe checkout page with the purchaser's email address" do
            @user = create(:user, email_address: build(:email_address))
            @user_upgrade = create(:gift_gold_upgrade, purchaser: @user)
            @checkout = @user_upgrade.create_checkout!

            assert_equal(@user.email_address.address, @checkout.customer_email)
          end
        end
      end

      context "for each upgrade type" do
        setup do
          skip unless UserUpgrade.enabled?
        end

        should "choose the right price in USD for a gold upgrade" do
          @user_upgrade = create(:self_gold_upgrade)
          @checkout = @user_upgrade.create_checkout!(country: "US")

          assert_equal(UserUpgrade.gold_price, @user_upgrade.payment_intent.amount)
          assert_equal("usd", @user_upgrade.payment_intent.currency)
        end

        should "choose the right price in USD for a platinum upgrade" do
          @user_upgrade = create(:self_platinum_upgrade)
          @checkout = @user_upgrade.create_checkout!(country: "US")

          assert_equal(UserUpgrade.platinum_price, @user_upgrade.payment_intent.amount)
          assert_equal("usd", @user_upgrade.payment_intent.currency)
        end

        should "choose the right price in USD for a gold to platinum upgrade" do
          @user_upgrade = create(:self_gold_to_platinum_upgrade)
          @checkout = @user_upgrade.create_checkout!(country: "US")

          assert_equal(UserUpgrade.gold_to_platinum_price, @user_upgrade.payment_intent.amount)
          assert_equal("usd", @user_upgrade.payment_intent.currency)
        end

        should "choose the right price in EUR for a gold upgrade" do
          @user_upgrade = create(:self_gold_upgrade)
          @checkout = @user_upgrade.create_checkout!(country: "DE")

          assert_equal(0.8 * UserUpgrade.gold_price, @user_upgrade.payment_intent.amount)
          assert_equal("eur", @user_upgrade.payment_intent.currency)
        end

        should "choose the right price in EUR for a platinum upgrade" do
          @user_upgrade = create(:self_platinum_upgrade)
          @checkout = @user_upgrade.create_checkout!(country: "DE")

          assert_equal(0.8 * UserUpgrade.platinum_price, @user_upgrade.payment_intent.amount)
          assert_equal("eur", @user_upgrade.payment_intent.currency)
        end

        should "choose the right price in EUR for a gold to platinum upgrade" do
          @user_upgrade = create(:self_gold_to_platinum_upgrade)
          @checkout = @user_upgrade.create_checkout!(country: "DE")

          assert_equal(0.8 * UserUpgrade.gold_to_platinum_price, @user_upgrade.payment_intent.amount)
          assert_equal("eur", @user_upgrade.payment_intent.currency)
        end
      end

      context "for each country" do
        setup do
          @user_upgrade = create(:self_gold_upgrade)
          skip unless UserUpgrade.enabled?
        end

        should "choose the right payment methods for US" do
          @checkout = @user_upgrade.create_checkout!(country: "US")

          assert_equal(["card"], @checkout.payment_method_types)
          assert_equal("usd", @user_upgrade.payment_intent.currency)
        end

        should "choose the right payment methods for AT" do
          @checkout = @user_upgrade.create_checkout!(country: "AT")

          assert_equal(["card", "eps"], @checkout.payment_method_types)
          assert_equal("eur", @user_upgrade.payment_intent.currency)
        end

        should "choose the right payment methods for BE" do
          @checkout = @user_upgrade.create_checkout!(country: "BE")

          assert_equal(["card", "bancontact"], @checkout.payment_method_types)
          assert_equal("eur", @user_upgrade.payment_intent.currency)
        end

        should "choose the right payment methods for DE" do
          @checkout = @user_upgrade.create_checkout!(country: "DE")

          assert_equal(["card", "giropay"], @checkout.payment_method_types)
          assert_equal("eur", @user_upgrade.payment_intent.currency)
        end

        should "choose the right payment methods for NL" do
          @checkout = @user_upgrade.create_checkout!(country: "NL")

          assert_equal(["card", "ideal"], @checkout.payment_method_types)
          assert_equal("eur", @user_upgrade.payment_intent.currency)
        end

        should "choose the right payment methods for PL" do
          @checkout = @user_upgrade.create_checkout!(country: "PL")

          assert_equal(["card", "p24"], @checkout.payment_method_types)
          assert_equal("eur", @user_upgrade.payment_intent.currency)
        end

        should "choose the right payment methods for an unsupported country" do
          @checkout = @user_upgrade.create_checkout!(country: "MX")

          assert_equal(["card"], @checkout.payment_method_types)
          assert_equal("usd", @user_upgrade.payment_intent.currency)
        end
      end
    end

    context "the #receipt_url method" do
      mock_stripe!

      context "a pending upgrade" do
        should "not have a receipt" do
          skip unless UserUpgrade.enabled?

          @user_upgrade = create(:self_gold_upgrade, status: "pending")
          @user_upgrade.create_checkout!

          assert_equal(nil, @user_upgrade.receipt_url)
        end
      end

      context "a complete upgrade" do
        # XXX not supported yet by stripe-ruby-mock
        should_eventually "have a receipt" do
          @user_upgrade = create(:self_gold_upgrade, status: "complete")
          @user_upgrade.create_checkout!

          assert_equal("xxx", @user_upgrade.receipt_url)
        end
      end
    end

    context "the #refund! method" do
      should_eventually "refund a Gold upgrade" do
        @user_upgrade = create(:self_gold_upgrade, recipient: create(:gold_user), status: "complete")
        @user_upgrade.create_checkout!
        @user_upgrade.refund!

        assert_equal("refunded", @user_upgrade.reload.status)
        assert_equal(User::Levels::MEMBER, @user_upgrade.recipient.level)
      end
    end
  end
end
