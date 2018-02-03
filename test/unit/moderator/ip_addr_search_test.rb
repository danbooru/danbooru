require "test_helper"

module Moderator
  class IpAddrSearchTest < ActiveSupport::TestCase
    context "an ip addr search" do
      setup do
        @user = FactoryGirl.create(:user)
        CurrentUser.user = @user
        CurrentUser.ip_addr = "127.0.0.1"
        Danbooru.config.stubs(:member_comment_time_threshold).returns(1.week.from_now)
        @comment = FactoryGirl.create(:comment)
        PoolArchive.stubs(:enabled?).returns(false)
        PostArchive.stubs(:enabled?).returns(false)
      end

      teardown do
        CurrentUser.user = nil
        CurrentUser.ip_addr = nil
      end

      should "find by ip addr" do
        @search = IpAddrSearch.new(:ip_addr => "127.0.0.1")
        assert_equal({@user => 1, @comment.post.uploader => 1}, @search.execute)
      end

      should "find by user id" do
        @search = IpAddrSearch.new(:user_id => @user.id.to_s)
        assert_equal({IPAddr.new("127.0.0.1") => 1}, @search.execute)
      end

      should "find by user name" do
        @search = IpAddrSearch.new(:user_name => @user.name)
        assert_equal({IPAddr.new("127.0.0.1") => 1}, @search.execute)
      end
    end
  end
end
