require "test_helper"

module Moderator
  class IpAddrSearchTest < ActiveSupport::TestCase
    context "an ip addr search" do
      setup do
        @user = create(:user, last_ip_addr: "127.0.0.1")
      end

      should "find by ip addr" do
        @search = IpAddrSearch.new(:ip_addr => "127.0.0.1")
        assert_equal({@user => 1}, @search.execute)
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
