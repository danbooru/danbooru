require "test_helper"

class DanbooruIpAddressTest < ActiveSupport::TestCase
  context "Danbooru::IpAddress" do
    context "#is_local?" do
      should "return true for IPv4 loopback addresses" do
        assert(Danbooru::IpAddress.parse("127.0.0.1").is_local?)
      end

      should "return true for IPv4 link-local addresses" do
        assert(Danbooru::IpAddress.parse("169.254.10.20").is_local?)
      end

      should "return true for IPv4 reserved addresses" do
        assert(Danbooru::IpAddress.parse("0.0.0.0").is_local?)
        assert(Danbooru::IpAddress.parse("100.64.0.1").is_local?)
        assert(Danbooru::IpAddress.parse("240.0.0.1").is_local?)
        assert(Danbooru::IpAddress.parse("255.255.255.255").is_local?)
        assert(Danbooru::IpAddress.parse("192.0.0.192").is_local?)
        assert(Danbooru::IpAddress.parse("198.18.0.1").is_local?)
        assert(Danbooru::IpAddress.parse("198.19.255.255").is_local?)
      end

      should "return true for IPv6 site-local addresses" do
        assert(Danbooru::IpAddress.parse("fec0::1").is_local?)
      end

      should "return true for IPv4 multicast addresses" do
        assert(Danbooru::IpAddress.parse("224.0.0.1").is_local?)
      end

      should "return true for IPv4 private addresses" do
        assert(Danbooru::IpAddress.parse("10.0.0.1").is_local?)
        assert(Danbooru::IpAddress.parse("172.16.0.1").is_local?)
        assert(Danbooru::IpAddress.parse("192.168.0.1").is_local?)
      end

      should "return true for IPv6 loopback and unspecified addresses" do
        assert(Danbooru::IpAddress.parse("::1").is_local?)
        assert(Danbooru::IpAddress.parse("::").is_local?)
      end

      should "return true for IPv6 link-local addresses" do
        assert(Danbooru::IpAddress.parse("fe80::1").is_local?)
      end

      should "return true for IPv6 multicast addresses" do
        assert(Danbooru::IpAddress.parse("ff00::1").is_local?)
      end

      should "return true for IPv6 unique-local addresses" do
        assert(Danbooru::IpAddress.parse("fc00::1").is_local?)
        assert(Danbooru::IpAddress.parse("fd00::1").is_local?)
      end

      should "return true for IPv4-mapped IPv6 addresses" do
        assert(Danbooru::IpAddress.parse("::ffff:127.0.0.1").is_local?)
        assert(Danbooru::IpAddress.parse("::7f00:1").is_local?)
      end

      should "return false for public IPv6 addresses that tunnel to IPv4 addresses" do
        assert_not(Danbooru::IpAddress.parse("2001:0:4136:e378:8000:63bf:3fff:fdd2").is_local?)
        assert_not(Danbooru::IpAddress.parse("2002:a9fe:a9fe::1").is_local?)
        assert_not(Danbooru::IpAddress.parse("64:ff9b::a9fe:a9fe").is_local?)
        assert_not(Danbooru::IpAddress.parse("64:ff9b:1::a9fe:a9fe").is_local?)
      end

      should "return false for public addresses" do
        assert_not(Danbooru::IpAddress.parse("8.8.8.8").is_local?)
        assert_not(Danbooru::IpAddress.parse("1.1.1.1").is_local?)
        assert_not(Danbooru::IpAddress.parse("100.63.255.255").is_local?)
        assert_not(Danbooru::IpAddress.parse("100.128.0.0").is_local?)
        assert_not(Danbooru::IpAddress.parse("192.0.1.1").is_local?)
        assert_not(Danbooru::IpAddress.parse("198.20.0.0").is_local?)
        assert_not(Danbooru::IpAddress.parse("2001:1::1").is_local?)
        assert_not(Danbooru::IpAddress.parse("::1:0:0:1").is_local?)
        assert_not(Danbooru::IpAddress.parse("2606:4700:4700::1111").is_local?)
        assert_not(Danbooru::IpAddress.parse("2001:4860:4860::8888").is_local?)
      end
    end

    context "#prohibited_for_outgoing?" do
      should "return true for local addresses" do
        assert(Danbooru::IpAddress.parse("127.0.0.1").prohibited_for_outgoing?)
        assert(Danbooru::IpAddress.parse("169.254.169.254").prohibited_for_outgoing?)
        assert(Danbooru::IpAddress.parse("::ffff:127.0.0.1").prohibited_for_outgoing?)
      end

      should "return true for IPv4-tunneled addresses" do
        assert(Danbooru::IpAddress.parse("2001:0:4136:e378:8000:63bf:3fff:fdd2").prohibited_for_outgoing?)
        assert(Danbooru::IpAddress.parse("2002:a9fe:a9fe::1").prohibited_for_outgoing?)
        assert(Danbooru::IpAddress.parse("64:ff9b::a9fe:a9fe").prohibited_for_outgoing?)
      end

      should "return false for public addresses" do
        assert_not(Danbooru::IpAddress.parse("8.8.8.8").prohibited_for_outgoing?)
        assert_not(Danbooru::IpAddress.parse("2606:4700:4700::1111").prohibited_for_outgoing?)
      end
    end

    context "#ipv4_tunneled?" do
      should "return true for Teredo, 6to4, and NAT64 addresses" do
        assert(Danbooru::IpAddress.parse("2001:0:4136:e378:8000:63bf:3fff:fdd2").ipv4_tunneled?)
        assert(Danbooru::IpAddress.parse("2002:a9fe:a9fe::1").ipv4_tunneled?)
        assert(Danbooru::IpAddress.parse("64:ff9b::a9fe:a9fe").ipv4_tunneled?)
        assert(Danbooru::IpAddress.parse("64:ff9b:1::a9fe:a9fe").ipv4_tunneled?)
      end

      should "return false for other addresses" do
        assert_not(Danbooru::IpAddress.parse("2001:1::1").ipv4_tunneled?)
        assert_not(Danbooru::IpAddress.parse("2001:4860:4860::8888").ipv4_tunneled?)
        assert_not(Danbooru::IpAddress.parse("::ffff:127.0.0.1").ipv4_tunneled?)
        assert_not(Danbooru::IpAddress.parse("127.0.0.1").ipv4_tunneled?)
      end
    end
  end
end
