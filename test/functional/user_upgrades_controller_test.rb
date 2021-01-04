require 'test_helper'

class UserUpgradesControllerTest < ActionDispatch::IntegrationTest
  context "The user upgrades controller" do
    context "new action" do
      should "render for a self upgrade to Gold" do
        @user = create(:user)
        get_auth new_user_upgrade_path, @user

        assert_response :success
      end

      should "render for a self upgrade to Platinum" do
        @user = create(:gold_user)
        get_auth new_user_upgrade_path, @user

        assert_response :success
      end

      should "render for a gifted upgrade to Gold" do
        @recipient = create(:user)
        get_auth new_user_upgrade_path(user_id: @recipient.id), create(:user)

        assert_response :success
      end

      should "render for a gifted upgrade to Platinum" do
        @recipient = create(:gold_user)
        get_auth new_user_upgrade_path(user_id: @recipient.id), create(:user)

        assert_response :success
      end

      should "render for an invalid gifted upgrade to a user who is already Platinum" do
        @recipient = create(:platinum_user)
        get_auth new_user_upgrade_path(user_id: @recipient.id), create(:user)

        assert_response :success
      end

      should "render for the country param" do
        get new_user_upgrade_path(country: "DE")

        assert_response :success
      end

      should "render for the promo param" do
        get new_user_upgrade_path(promo: "true")

        assert_response :success
      end

      should "render for an anonymous user" do
        get new_user_upgrade_path

        assert_response :success
      end
    end

    context "index action" do
      setup do
        @self_upgrade = create(:self_gold_upgrade)
        @gift_upgrade = create(:gift_gold_upgrade)
      end

      should "show the purchaser's upgrades to the purchaser" do
        get_auth user_upgrades_path, @gift_upgrade.purchaser

        assert_response :success
        assert_select "#user-upgrade-#{@gift_upgrade.id}", count: 1
      end

      should "show the recipient's upgrades to the recipient" do
        get_auth user_upgrades_path, @gift_upgrade.recipient

        assert_response :success
        assert_select "#user-upgrade-#{@gift_upgrade.id}", count: 1
      end

      should "not show upgrades to unrelated users" do
        get_auth user_upgrades_path, create(:user)

        assert_response :success
        assert_select "#user-upgrade-#{@gift_upgrade.id}", count: 0
      end
    end

    context "show action" do
      context "for a completed upgrade" do
        should "render for a self upgrade" do
          @user_upgrade = create(:self_gold_upgrade, status: "complete")
          get_auth user_upgrade_path(@user_upgrade), @user_upgrade.purchaser

          assert_response :success
        end

        should "render for a gift upgrade for the purchaser" do
          @user_upgrade = create(:gift_gold_upgrade, status: "complete")
          get_auth user_upgrade_path(@user_upgrade), @user_upgrade.purchaser

          assert_response :success
        end

        should "render for a gift upgrade for the recipient" do
          @user_upgrade = create(:gift_gold_upgrade, status: "complete")
          get_auth user_upgrade_path(@user_upgrade), @user_upgrade.recipient

          assert_response :success
        end

        should "render for the site owner" do
          @user_upgrade = create(:self_gold_upgrade, status: "complete")
          get_auth user_upgrade_path(@user_upgrade), create(:owner_user)

          assert_response :success
        end

        should "be inaccessible to other users" do
          @user_upgrade = create(:self_gold_upgrade, status: "complete")
          get_auth user_upgrade_path(@user_upgrade), create(:user)

          assert_response 403
        end
      end

      context "for a refunded upgrade" do
        should "render" do
          @user_upgrade = create(:self_gold_upgrade, status: "refunded")
          get_auth user_upgrade_path(@user_upgrade), @user_upgrade.purchaser

          assert_response :success
        end
      end

      context "for a pending upgrade" do
        should "render" do
          @user_upgrade = create(:self_gold_upgrade, status: "pending")
          get_auth user_upgrade_path(@user_upgrade), @user_upgrade.purchaser

          assert_response :success
        end
      end
    end

    context "receipt action" do
      mock_stripe!

      setup do
        @user_upgrade = create(:gift_gold_upgrade, status: "complete")
        @user_upgrade.create_checkout!
      end

      should "not allow unauthorized users to view the receipt" do
        get_auth receipt_user_upgrade_path(@user_upgrade), create(:user)

        assert_response 403
      end

      should "not allow the recipient to view the receipt" do
        get_auth receipt_user_upgrade_path(@user_upgrade), @user_upgrade.recipient

        assert_response 403
      end

      should "not allow the purchaser to view a pending receipt" do
        @user_upgrade.update!(status: "pending")
        get_auth receipt_user_upgrade_path(@user_upgrade), @user_upgrade.purchaser

        assert_response 403
      end

      # XXX not supported yet by stripe-ruby-mock
      should_eventually "allow the purchaser to view the receipt" do
        get_auth receipt_user_upgrade_path(@user_upgrade), @user_upgrade.purchaser

        assert_redirected_to "xxx"
      end

      # XXX not supported yet by stripe-ruby-mock
      should_eventually "allow the site owner to view the receipt" do
        get_auth receipt_user_upgrade_path(@user_upgrade), create(:owner_user)

        assert_redirected_to "xxx"
      end
    end

    context "payment action" do
      setup do
        @user_upgrade = create(:gift_gold_upgrade, status: "complete")
        @user_upgrade.create_checkout!
      end

      should "not allow unauthorized users to view the receipt" do
        get_auth payment_user_upgrade_path(@user_upgrade), @user_upgrade.purchaser

        assert_response 403
      end

      # XXX not supported yet by stripe-ruby-mock
      should_eventually "allow the site owner to view the receipt" do
        get_auth payment_user_upgrade_path(@user_upgrade), create(:owner_user)

        assert_redirected_to "xxx"
      end
    end

    context "refund action" do
      mock_stripe!

      context "for a self upgrade" do
        context "to Gold" do
          should_eventually "refund the upgrade" do
            @user_upgrade = create(:self_gold_upgrade, recipient: create(:gold_user), status: "complete")
            @user_upgrade.create_checkout!

            put_auth refund_user_upgrade_path(@user_upgrade), create(:owner_user), xhr: true

            assert_response :success
            assert_equal("refunded", @user_upgrade.reload.status)
            assert_equal(User::Levels::MEMBER, @user_upgrade.recipient.level)
          end
        end
      end

      context "for a gifted upgrade" do
        context "to Platinum" do
          should_eventually "refund the upgrade" do
            @user_upgrade = create(:gift_platinum_upgrade, recipient: create(:platinum_user), status: "complete")
            @user_upgrade.create_checkout!

            put_auth refund_user_upgrade_path(@user_upgrade), create(:owner_user), xhr: true

            assert_response :success
            assert_equal("refunded", @user_upgrade.reload.status)
            assert_equal(User::Levels::MEMBER, @user_upgrade.recipient.level)
          end
        end
      end

      should "not allow unauthorized users to create a refund" do
        @user_upgrade = create(:self_gold_upgrade, recipient: create(:gold_user), status: "complete")
        @user_upgrade.create_checkout!

        put_auth refund_user_upgrade_path(@user_upgrade), @user_upgrade.purchaser, xhr: true

        assert_response 403
        assert_equal("complete", @user_upgrade.reload.status)
        assert_equal(User::Levels::GOLD, @user_upgrade.recipient.level)
      end
    end

    context "create action" do
      mock_stripe!

      context "for a self upgrade" do
        context "to Gold" do
          should "create a pending upgrade" do
            @user = create(:member_user)

            post_auth user_upgrades_path(user_id: @user.id), @user, params: { upgrade_type: "gold" }, xhr: true
            assert_response :success

            @user_upgrade = @user.purchased_upgrades.last
            assert_equal(@user, @user_upgrade.purchaser)
            assert_equal(@user, @user_upgrade.recipient)
            assert_equal("gold", @user_upgrade.upgrade_type)
            assert_equal("pending", @user_upgrade.status)
            assert_not_nil(@user_upgrade.stripe_id)
            assert_match(/redirectToCheckout/, response.body)
          end
        end

        context "to Platinum" do
          should "create a pending upgrade" do
            @user = create(:member_user)

            post_auth user_upgrades_path(user_id: @user.id), @user, params: { upgrade_type: "platinum" }, xhr: true
            assert_response :success

            @user_upgrade = @user.purchased_upgrades.last
            assert_equal(@user, @user_upgrade.purchaser)
            assert_equal(@user, @user_upgrade.recipient)
            assert_equal("platinum", @user_upgrade.upgrade_type)
            assert_equal("pending", @user_upgrade.status)
            assert_not_nil(@user_upgrade.stripe_id)
            assert_match(/redirectToCheckout/, response.body)
          end
        end

        context "from Gold to Platinum" do
          should "create a pending upgrade" do
            @user = create(:member_user)

            post_auth user_upgrades_path(user_id: @user.id), @user, params: { upgrade_type: "gold_to_platinum" }, xhr: true
            assert_response :success

            @user_upgrade = @user.purchased_upgrades.last
            assert_equal(@user, @user_upgrade.purchaser)
            assert_equal(@user, @user_upgrade.recipient)
            assert_equal("gold_to_platinum", @user_upgrade.upgrade_type)
            assert_equal("pending", @user_upgrade.status)
            assert_not_nil(@user_upgrade.stripe_id)
            assert_match(/redirectToCheckout/, response.body)
          end
        end
      end

      context "for a gifted upgrade" do
        context "to Gold" do
          should "create a pending upgrade" do
            @recipient = create(:member_user)
            @purchaser = create(:member_user)

            post_auth user_upgrades_path(user_id: @recipient.id), @purchaser, params: { upgrade_type: "gold" }, xhr: true
            assert_response :success

            @user_upgrade = @purchaser.purchased_upgrades.last
            assert_equal(@purchaser, @user_upgrade.purchaser)
            assert_equal(@recipient, @user_upgrade.recipient)
            assert_equal("gold", @user_upgrade.upgrade_type)
            assert_equal("pending", @user_upgrade.status)
            assert_not_nil(@user_upgrade.stripe_id)
            assert_match(/redirectToCheckout/, response.body)
          end
        end

        context "to Platinum" do
          should "create a pending upgrade" do
            @recipient = create(:member_user)
            @purchaser = create(:member_user)

            post_auth user_upgrades_path(user_id: @recipient.id), @purchaser, params: { upgrade_type: "platinum" }, xhr: true
            assert_response :success

            @user_upgrade = @purchaser.purchased_upgrades.last
            assert_equal(@purchaser, @user_upgrade.purchaser)
            assert_equal(@recipient, @user_upgrade.recipient)
            assert_equal("platinum", @user_upgrade.upgrade_type)
            assert_equal("pending", @user_upgrade.status)
            assert_not_nil(@user_upgrade.stripe_id)
            assert_match(/redirectToCheckout/, response.body)
          end
        end

        context "from Gold to Platinum" do
          should "create a pending upgrade" do
            @recipient = create(:gold_user)
            @purchaser = create(:member_user)

            post_auth user_upgrades_path(user_id: @recipient.id), @purchaser, params: { upgrade_type: "gold_to_platinum" }, xhr: true
            assert_response :success

            @user_upgrade = @purchaser.purchased_upgrades.last
            assert_equal(@purchaser, @user_upgrade.purchaser)
            assert_equal(@recipient, @user_upgrade.recipient)
            assert_equal("gold_to_platinum", @user_upgrade.upgrade_type)
            assert_equal("pending", @user_upgrade.status)
            assert_not_nil(@user_upgrade.stripe_id)
            assert_match(/redirectToCheckout/, response.body)
          end
        end
      end
    end
  end
end
