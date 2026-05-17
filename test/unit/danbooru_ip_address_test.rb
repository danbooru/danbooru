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
        assert(Danbooru::IpAddress.parse("2002:a9fe:a9fe::1").is_local?)
        assert(Danbooru::IpAddress.parse("64:ff9b::a9fe:a9fe").is_local?)
        assert(Danbooru::IpAddress.parse("64:ff9b:1::a9fe:a9fe").is_local?)
      end

      should "return false for public addresses" do
        assert_not(Danbooru::IpAddress.parse("8.8.8.8").is_local?)
        assert_not(Danbooru::IpAddress.parse("1.1.1.1").is_local?)
        assert_not(Danbooru::IpAddress.parse("100.63.255.255").is_local?)
        assert_not(Danbooru::IpAddress.parse("100.128.0.0").is_local?)
        assert_not(Danbooru::IpAddress.parse("2606:4700:4700::1111").is_local?)
        assert_not(Danbooru::IpAddress.parse("2001:4860:4860::8888").is_local?)
      end
    end
  end
end
