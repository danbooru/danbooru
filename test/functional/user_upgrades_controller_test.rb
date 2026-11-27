require "test_helper"

class UserUpgradesControllerTest < ActionDispatch::IntegrationTest
  context "The user upgrades controller" do
    setup do
      Danbooru.config.stubs(:user_upgrades_enabled?).returns(true)
    end

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

        should "render for superadmins" do
          @user_upgrade = create(:self_gold_upgrade, status: "complete")
          get_auth user_upgrade_path(@user_upgrade), create(:superadmin_user)

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
      setup do
        @user_upgrade = create(:gift_gold_upgrade, status: "complete")
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
      should_eventually "allow superadmins to view the receipt" do
        get_auth receipt_user_upgrade_path(@user_upgrade), create(:superadmin_user)

        assert_redirected_to "xxx"
      end
    end

    context "payment action" do
      setup do
        @user_upgrade = create(:gift_gold_upgrade, status: "complete")
      end

      should "not allow unauthorized users to view the receipt" do
        get_auth payment_user_upgrade_path(@user_upgrade), @user_upgrade.purchaser

        assert_response 403
      end

      # XXX not supported yet by stripe-ruby-mock
      should_eventually "allow superadmins to view the receipt" do
        get_auth payment_user_upgrade_path(@user_upgrade), create(:superadmin_user)

        assert_redirected_to "xxx"
      end
    end

    context "refund action" do
      context "for a self upgrade" do
        context "to Gold" do
          should_eventually "refund the upgrade" do
            @user_upgrade = create(:self_gold_upgrade, recipient: create(:gold_user), status: "complete")
            @user_upgrade.create_checkout!

            put_auth refund_user_upgrade_path(@user_upgrade), create(:superadmin_user), xhr: true

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

            put_auth refund_user_upgrade_path(@user_upgrade), create(:superadmin_user), xhr: true

            assert_response :success
            assert_equal("refunded", @user_upgrade.reload.status)
            assert_equal(User::Levels::MEMBER, @user_upgrade.recipient.level)
          end
        end
      end

      should "not allow unauthorized users to create a refund" do
        @user_upgrade = create(:self_gold_upgrade, recipient: create(:gold_user), status: "complete")

        put_auth refund_user_upgrade_path(@user_upgrade), @user_upgrade.purchaser, xhr: true

        assert_response 403
        assert_equal("complete", @user_upgrade.reload.status)
        assert_equal(User::Levels::GOLD, @user_upgrade.recipient.level)
      end
    end
  end

  context "The user upgrades controller new action" do
    should "disable the purchase button when upgrades can't be purchased" do
      Danbooru.config.stubs(:user_upgrades_enabled?).returns(true)
      get_auth new_user_upgrade_path, create(:member_user)

      assert_response :success
      assert_select "form[action^='/user_upgrades'] button[disabled]", text: "Upgrade to Gold"
      assert_select "form[action^='/user_upgrades'] button:not([disabled])", count: 0
      assert_select "a[href='#{redeem_upgrade_codes_path}']"
    end
  end

  context "The user upgrades controller create action" do
    setup do
      @user = create(:member_user)
    end

    should "not allow anonymous users to create an upgrade" do
      assert_no_difference("UserUpgrade.count") do
        post user_upgrades_path(format: :json), params: { upgrade_type: "gold", payment_processor: "stripe" }
        assert_response 403
      end
    end

    should "not allow anonymous users to create a gifted upgrade" do
      assert_no_difference("UserUpgrade.count") do
        post user_upgrades_path(format: :json), params: { user_id: @user.id, upgrade_type: "gold", payment_processor: "stripe" }
        assert_response 403
      end
    end

    should "not allow members to create an upgrade" do
      assert_no_difference("UserUpgrade.count") do
        post_auth user_upgrades_path(format: :json), @user, params: { upgrade_type: "gold", payment_processor: "stripe" }
        assert_response 403
      end
    end

    should "not allow members to create a gifted upgrade" do
      assert_no_difference("UserUpgrade.count") do
        post_auth user_upgrades_path(format: :json), create(:member_user), params: { user_id: @user.id, upgrade_type: "gold", payment_processor: "stripe" }
        assert_response 403
      end
    end

    should "not allow Gold users to create an upgrade" do
      assert_no_difference("UserUpgrade.count") do
        post_auth user_upgrades_path(format: :json), create(:gold_user), params: { upgrade_type: "gold_to_platinum", payment_processor: "stripe" }
        assert_response 403
      end
    end

    should "not allow admins to create an upgrade" do
      assert_no_difference("UserUpgrade.count") do
        post_auth user_upgrades_path(format: :json), create(:admin_user), params: { user_id: @user.id, upgrade_type: "gold", payment_processor: "stripe" }
        assert_response 403
      end
    end

    should "not allow superadmins to create an upgrade" do
      assert_no_difference("UserUpgrade.count") do
        post_auth user_upgrades_path(format: :json), create(:superadmin_user), params: { user_id: @user.id, upgrade_type: "gold", payment_processor: "stripe" }
        assert_response 403
      end
    end
  end
end
