require 'test_helper'

class SuperVoterTest < ActiveSupport::TestCase
  def setup
    super
    @user = FactoryGirl.create(:user)
  end

  context "#init" do
    setup do
      @admin = FactoryGirl.create(:admin_user)
      @user_mock = mock("user")
      @user_mock.expects(:user_id).twice.returns(@user.id)
      @admin_mock = mock("admin")
      @admin_mock.expects(:user_id).twice.returns(@admin.id)
      PostVoteSimilarity.any_instance.stubs(:calculate_positive).returns([@admin_mock, @user_mock])
    end

    should "create super voter objects" do
      assert_difference("SuperVoter.count", 2) do
        SuperVoter.init!
      end
    end
  end

  context "creation" do
    should "update the is_super_voter field on the user object" do
      FactoryGirl.create(:super_voter, user: @user)
      @user.reload
      assert_equal(true, @user.is_super_voter?)
    end
  end

  context "destruction" do
    should "update the is_super_voter field on the user object" do
      voter = FactoryGirl.create(:super_voter, user: @user)
      voter.destroy
      @user.reload
      assert_equal(false, @user.is_super_voter?)
    end
  end
end
