require 'test_helper'

class TokenBucketTest < ActiveSupport::TestCase
  context "#add!" do
    setup do
      @user = FactoryBot.create(:user)
      TokenBucket.create(user_id: @user.id, last_touched_at: 1.minute.ago, token_count: 0)
    end

    should "work" do
      @user.token_bucket.add!
      assert_operator(@user.token_bucket.token_count, :>, 0)
      @user.reload
      assert_operator(@user.token_bucket.token_count, :>, 0)
    end
  end

  context "#consume!" do
    setup do
      @user = FactoryBot.create(:user)
      TokenBucket.create(user_id: @user.id, last_touched_at: 1.minute.ago, token_count: 1)
    end

    should "work" do
      @user.token_bucket.consume!
      assert_operator(@user.token_bucket.token_count, :<, 1)
      @user.reload     
      assert_operator(@user.token_bucket.token_count, :<, 1)
    end
  end

  context "#throttled?" do
    setup do
      @user = FactoryBot.create(:user)
      TokenBucket.create(user_id: @user.id, last_touched_at: 1.minute.ago, token_count: 0)
    end

    should "work" do
      assert(!@user.token_bucket.throttled?)
      assert_operator(@user.token_bucket.token_count, :<, 60)
      @user.reload
      assert_operator(@user.token_bucket.token_count, :<, 60)
    end
  end
end
