require 'test_helper'

class IpBanTest < ActiveSupport::TestCase
  setup do
    CurrentUser.user = FactoryBot.create(:mod_user)
    CurrentUser.ip_addr = "127.0.0.1"
  end

  teardown do
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
  end

  should "be able to ban a user" do
    ip_ban = create(:ip_ban, ip_addr: "1.2.3.4")

    assert_equal("1.2.3.4", ip_ban.subnetted_ip)
    assert(IpBan.is_banned?("1.2.3.4"))
  end

  should "be able to ban a subnet" do
    ip_ban = create(:ip_ban, ip_addr: "1.2.3.4/24")

    assert_equal("1.2.3.0/24", ip_ban.subnetted_ip)
    assert(IpBan.is_banned?("1.2.3.0"))
    assert(IpBan.is_banned?("1.2.3.255"))
  end

  context "validation" do
    subject { build(:ip_ban) }

    should allow_value("1.2.3.4").for(:ip_addr)
    should allow_value("1.2.3.4/24").for(:ip_addr)
    should allow_value("ABCD::1234").for(:ip_addr)
    should allow_value("ABCD::1234/64").for(:ip_addr)

    should_not allow_value("").for(:ip_addr)
    should_not allow_value("foo").for(:ip_addr)
    should_not allow_value("10.0.0.1").for(:ip_addr)
    should_not allow_value("127.0.0.1").for(:ip_addr)
    should_not allow_value("1.2.3.4/16").for(:ip_addr)
    should_not allow_value("ABCD::1234/32").for(:ip_addr)
  end
end
