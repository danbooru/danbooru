require 'test_helper'

class UserUpgradesControllerTest < ActionController::TestCase
  def get_stripe_token
    Stripe::Token.create(
      :card => {
        :number => "4242424242424242",
        :exp_month => 1,
        :exp_year => 1.year.from_now.year,
        :cvc => "123"
      }
    )
  end

  setup do
    @user = FactoryGirl.create(:user)
  end

  context "#create" do
    context "for basic -> gold" do
      should "promote the account" do
        VCR.use_cassette("stripe-basic-to-gold", :record => :once) do
          post :create, {:stripeToken => get_stripe_token.id, :desc => "Upgrade to Gold", :email => "nowhere@donmai.us"}, {:user_id => @user.id}
        end
        assert_redirected_to user_upgrade_path
        @user.reload
        assert_equal(User::Levels::GOLD, @user.level)
      end
    end

    context "for basic -> platinum" do
      should "promote the account" do
        VCR.use_cassette("stripe-basic-to-plat", :record => :once) do
          post :create, {:stripeToken => get_stripe_token.id, :desc => "Upgrade to Platinum", :email => "nowhere@donmai.us"}, {:user_id => @user.id}
        end
        assert_redirected_to user_upgrade_path
        @user.reload
        assert_equal(User::Levels::PLATINUM, @user.level)
      end
    end

    context "for gold -> platinum" do
      context "when the user is gold" do
        setup do
          @user.update_attribute(:level, User::Levels::GOLD)
        end

        should "promote the account" do
          VCR.use_cassette("stripe-gold-to-plat", :record => :once) do
            post :create, {:stripeToken => get_stripe_token.id, :desc => "Upgrade Gold to Platinum", :email => "nowhere@donmai.us"}, {:user_id => @user.id}
          end
          assert_redirected_to user_upgrade_path
          @user.reload
          assert_equal(User::Levels::PLATINUM, @user.level)
        end
      end

      context "when the user is not gold" do
        should "fail" do
          VCR.use_cassette("stripe-gold-to-plat-bad", :record => :once) do
            post :create, {:stripeToken => get_stripe_token.id, :desc => "Upgrade Gold to Platinum", :email => "nowhere@donmai.us"}, {:user_id => @user.id}
          end
          assert_response 422
          @user.reload
          assert_equal(User::Levels::MEMBER, @user.level)
        end        
      end
    end
  end

  context "#new" do
    context "for safe mode" do
      setup do
        CurrentUser.stubs(:safe_mode?).returns(true)
      end

      should "render" do
        get :new, {}, {:user_id => @user.id}
        assert_response :success
      end      
    end

    context "for default mode" do
      should "render" do
        get :new, {}, {:user_id => @user.id}
        assert_response :success
      end
    end
  end

  context "#show" do
    context "with disable=true" do
      should "render" do
        get :show, {}, {:user_id => @user.id}, {:disable => true}
        assert_response :success
      end
    end

    context "with success=true" do
      should "render" do
        get :show, {}, {:user_id => @user.id}, {:success => true}
        assert_response :success
      end
    end

    context "with error=true" do
      should "render" do
        get :show, {}, {:user_id => @user.id}, {:error => true}
        assert_response :success
      end
    end
  end
end
