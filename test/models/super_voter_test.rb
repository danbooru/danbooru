require 'test_helper'

class SuperVoterTest < ActiveSupport::TestCase
  def setup
    super
    @user = FactoryGirl.create(:user)
  end

  context "#init" do
    setup do
      @admin = FactoryGirl.create(:admin_user)
      Reports::UserSimilarity.any_instance.stubs(:fetch_similar_user_ids).returns("#{@user.id} 1")
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
