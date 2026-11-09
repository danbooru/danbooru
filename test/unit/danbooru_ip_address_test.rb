require "test_helper"

class DanbooruIpAddressTest < ActiveSupport::TestCase
  context "Danbooru::IpAddress" do
    context ".parse" do
      should "return nil for invalid addresses" do
        assert_nil(Danbooru::IpAddress.parse(""))
        assert_nil(Danbooru::IpAddress.parse("abc"))
        assert_nil(Danbooru::IpAddress.parse("1.2.3"))
        assert_nil(Danbooru::IpAddress.parse("1.2.3.256"))
        assert_nil(Danbooru::IpAddress.parse("1.2.3.4/33"))
        assert_nil(Danbooru::IpAddress.parse("fe80::1%eth0"))
      end

      should "strip whitespace" do
        assert_equal("1.2.3.4", Danbooru::IpAddress.parse(" 1.2.3.4\n").to_s)
      end

      should "accept other IpAddress objects" do
        ip = Danbooru::IpAddress.parse("1.2.3.4")
        assert_equal(ip, Danbooru::IpAddress.new(ip))
      end
    end

    context "#to_s" do
      should "return the address for single addresses" do
        assert_equal("1.2.3.4", Danbooru::IpAddress.parse("1.2.3.4").to_s)
        assert_equal("1.2.3.4", Danbooru::IpAddress.parse("1.2.3.4/32").to_s)
        assert_equal("2001:db8::1", Danbooru::IpAddress.parse("2001:DB8:0::1").to_s)
      end

      should "return the network and prefix for subnets" do
        assert_equal("1.2.3.0/24", Danbooru::IpAddress.parse("1.2.3.4/24").to_s)
        assert_equal("2001:db8::/64", Danbooru::IpAddress.parse("2001:db8::1/64").to_s)
        assert_equal("0.0.0.0/0", Danbooru::IpAddress.parse("0.0.0.0/0").to_s)
      end
    end

    context "when saved to the database" do
      should "round trip through IpAddressType" do
        %w[8.8.8.8 9.9.9.0/24 2606:4700::1111 2001:4860::/64].each do |ip|
          ip_ban = create(:ip_ban, ip_addr: ip)
          assert_equal(ip, ip_ban.reload.ip_addr.to_s)
        end
      end
    end

    context "#prefix" do
      should "return the prefix length" do
        assert_equal(24, Danbooru::IpAddress.parse("1.2.3.4/24").prefix)
        assert_equal(32, Danbooru::IpAddress.parse("1.2.3.4").prefix)
        assert_equal(128, Danbooru::IpAddress.parse("::1").prefix)
      end
    end

    context "#size" do
      should "return the number of addresses in the subnet" do
        assert_equal(1, Danbooru::IpAddress.parse("1.2.3.4").size)
        assert_equal(256, Danbooru::IpAddress.parse("1.2.3.4/24").size)
        assert_equal(2**32, Danbooru::IpAddress.parse("0.0.0.0/0").size)
        assert_equal(1, Danbooru::IpAddress.parse("::1").size)
        assert_equal(2**64, Danbooru::IpAddress.parse("2001:db8::/64").size)
      end
    end

    context "#ipv4? and #ipv6?" do
      should "return the address family" do
        assert(Danbooru::IpAddress.parse("1.2.3.4").ipv4?)
        assert_not(Danbooru::IpAddress.parse("1.2.3.4").ipv6?)
        assert(Danbooru::IpAddress.parse("::1").ipv6?)
        assert_not(Danbooru::IpAddress.parse("::1").ipv4?)
      end
    end

    context "#subnet" do
      should "convert public addresses to a /24 or /64 subnet" do
        assert_equal("1.2.3.0/24", Danbooru::IpAddress.parse("1.2.3.4").subnet.to_s)
        assert_equal("2001:4860:4860::/64", Danbooru::IpAddress.parse("2001:4860:4860::8888").subnet.to_s)
      end

      should "not change local addresses, Tor addresses, or subnets" do
        assert_equal("127.0.0.1", Danbooru::IpAddress.parse("127.0.0.1").subnet.to_s)
        assert_equal("2405:8100:8000::1", Danbooru::IpAddress.parse("2405:8100:8000::1").subnet.to_s)
        assert_equal("1.2.0.0/16", Danbooru::IpAddress.parse("1.2.0.0/16").subnet.to_s)
      end
    end

    context "#supernet" do
      should "return the containing subnet" do
        assert_equal("1.2.0.0/16", Danbooru::IpAddress.parse("1.2.3.4").supernet(16).to_s)
      end
    end

    context "#include?" do
      should "return true for addresses and subnets inside the subnet" do
        subnet = Danbooru::IpAddress.parse("1.2.0.0/16")

        assert(subnet.include?("1.2.3.4"))
        assert(subnet.include?("1.2.3.0/24"))
        assert(subnet.include?(Danbooru::IpAddress.parse("1.2.255.255")))
      end

      should "return false for addresses and subnets outside the subnet" do
        assert_not(Danbooru::IpAddress.parse("1.2.0.0/16").include?("1.3.0.0"))
        assert_not(Danbooru::IpAddress.parse("1.2.3.0/24").include?("1.2.0.0/16"))
      end

      should "return false for addresses of a different family" do
        assert_not(Danbooru::IpAddress.parse("0.0.0.0/0").include?("::1"))
        assert_not(Danbooru::IpAddress.parse("::/0").include?("1.2.3.4"))
        assert_not(Danbooru::IpAddress.parse("1.2.3.0/24").include?("::ffff:1.2.3.4"))
      end
    end

    context "#===" do
      should "return true if the address is in the given subnet" do
        assert_operator(Danbooru::IpAddress.parse("1.2.3.4"), :===, "1.2.0.0/16")
        assert_not_operator(Danbooru::IpAddress.parse("1.3.3.4"), :===, "1.2.0.0/16")
      end
    end

    context "equality" do
      should "treat equivalent addresses as equal" do
        assert_equal(Danbooru::IpAddress.parse("1.2.3.4"), Danbooru::IpAddress.parse("1.2.3.4/32"))
        assert_equal(Danbooru::IpAddress.parse("1.2.3.4/24"), Danbooru::IpAddress.parse("1.2.3.0/24"))
        assert_not_equal(Danbooru::IpAddress.parse("1.2.3.4"), Danbooru::IpAddress.parse("1.2.3.5"))
        assert_equal(1, [Danbooru::IpAddress.parse("::1"), Danbooru::IpAddress.parse("0::1")].uniq.size)
      end
    end

    context "#<=>" do
      should "sort smaller subnets first, then by network address" do
        ips = %w[1.2.3.4 1.2.0.0/16 1.2.3.0/24 1.2.3.3].map { |ip| Danbooru::IpAddress.parse(ip) }
        assert_equal(%w[1.2.3.3 1.2.3.4 1.2.3.0/24 1.2.0.0/16], ips.sort.map(&:to_s))
      end

      should "sort IPv4 and IPv6 addresses with the same prefix" do
        ips = %w[1.2.3.0/24 ::/24].map { |ip| Danbooru::IpAddress.parse(ip) }
        assert_equal(%w[1.2.3.0/24 ::/24], ips.sort.map(&:to_s))
      end
    end

    context "#is_tor?" do
      should "return true for Cloudflare's Tor addresses" do
        assert(Danbooru::IpAddress.parse("2405:8100:8000::1").is_tor?)
        assert_not(Danbooru::IpAddress.parse("2405:8100:8001::1").is_tor?)
      end
    end

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
