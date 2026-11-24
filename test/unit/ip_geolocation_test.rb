require "test_helper"

class IpGeolocationTest < ActiveSupport::TestCase
  def mock_ipregistry(ip_addr, status: 200, **response)
    mock_request("https://api.ipregistry.co/#{ip_addr}", status: status, body: response.to_json)
  end

  context "IpGeolocation: " do
    should "have a name for every IP type" do
      assert_equal(IpGeolocation.ip_types.keys, IpGeolocation::IP_TYPE_NAMES.keys)
    end

    context "the find_or_lookup! method" do
      setup do
        Danbooru.config.stubs(:ip_intelligence_provider).returns("ipregistry://ipregistry-key")
      end

      should "look up and save the IP if it hasn't been seen before" do
        mock_ipregistry(
          "45.83.91.1",
          connection: { asn: 9009, organization: "M247 Europe SRL", route: "45.83.91.0/24", type: "hosting" },
          location: { country: { code: "US" }, city: "Ashburn" },
          carrier: { name: nil },
          security: { is_vpn: true, is_cloud_provider: true },
          time_zone: { id: "America/New_York" },
          currency: { code: "USD" },
        )

        ip = assert_difference("IpGeolocation.count", 1) { IpGeolocation.find_or_lookup!("45.83.91.1") }

        assert_equal("45.83.91.1", ip.ip_addr.to_s)
        assert_equal("ipregistry", ip.provider)
        assert_equal("Ashburn", ip.city)
        assert_equal(true, ip.is_proxy?)
        assert_equal("vpn", ip.ip_type)
        assert_equal("America/New_York", ip.time_zone)
        assert_equal("M247 Europe SRL", ip.response.dig("connection", "organization"))
        assert_equal(%w[carrier connection location security], ip.response.keys.sort)
        assert_in_delta(Time.zone.now, ip.checked_at, 1.minute)
      end

      should "mark ISP and mobile IPs as not proxies" do
        mock_ipregistry("37.173.153.166", connection: { type: "isp" }, carrier: { name: "Free Mobile" }, security: { is_vpn: false })
        mock_ipregistry("73.1.2.3", connection: { type: "isp" }, security: { is_vpn: false })

        assert_equal(["mobile", false], IpGeolocation.find_or_lookup!("37.173.153.166").slice(:ip_type, :is_proxy).values)
        assert_equal(["isp", false], IpGeolocation.find_or_lookup!("73.1.2.3").slice(:ip_type, :is_proxy).values)
      end

      should "mark hosting, proxy, VPN, relay, and Tor IPs as proxies" do
        mock_ipregistry("45.83.91.1", connection: { type: "hosting" })
        mock_ipregistry("45.83.91.2", connection: { type: "isp" }, security: { is_proxy: true })
        mock_ipregistry("45.83.91.3", connection: { type: "isp" }, security: { is_residential_proxy: true })
        mock_ipregistry("45.83.91.4", connection: { type: "isp" }, security: { is_vpn: true })
        mock_ipregistry("45.83.91.5", connection: { type: "isp" }, security: { is_relay: true })
        mock_ipregistry("45.83.91.6", connection: { type: "isp" }, security: { is_tor: true })

        assert_equal(["hosting", true], IpGeolocation.find_or_lookup!("45.83.91.1").slice(:ip_type, :is_proxy).values)
        assert_equal(["proxy", true], IpGeolocation.find_or_lookup!("45.83.91.2").slice(:ip_type, :is_proxy).values)
        assert_equal(["residential_proxy", true], IpGeolocation.find_or_lookup!("45.83.91.3").slice(:ip_type, :is_proxy).values)
        assert_equal(["vpn", true], IpGeolocation.find_or_lookup!("45.83.91.4").slice(:ip_type, :is_proxy).values)
        assert_equal(["relay", true], IpGeolocation.find_or_lookup!("45.83.91.5").slice(:ip_type, :is_proxy).values)
        assert_equal(["tor", true], IpGeolocation.find_or_lookup!("45.83.91.6").slice(:ip_type, :is_proxy).values)
      end

      should "not mark IPs as proxies only because they're flagged as abusers or the type is unknown" do
        mock_ipregistry("45.83.91.1", connection: { type: "isp" }, security: { is_abuser: true, is_threat: true })
        mock_ipregistry("45.83.91.2", location: { city: "Ashburn" })

        assert_equal(["isp", false], IpGeolocation.find_or_lookup!("45.83.91.1").slice(:ip_type, :is_proxy).values)
        assert_equal([nil, false], IpGeolocation.find_or_lookup!("45.83.91.2").slice(:ip_type, :is_proxy).values)
      end

      should "return the saved IP without looking it up again if it was checked recently" do
        ip = create(:ip_geolocation, ip_addr: "45.83.91.1", city: "Saved", checked_at: 1.day.ago)
        Danbooru::Http.any_instance.expects(:get).never

        assert_equal(ip, IpGeolocation.find_or_lookup!("45.83.91.1"))
        assert_equal("Saved", ip.reload.city)
      end

      should "look up the IP again if it was last checked too long ago" do
        ip = create(:ip_geolocation, ip_addr: "45.83.91.1", city: "Old", checked_at: 30.days.ago)
        mock_ipregistry("45.83.91.1", location: { city: "New" })

        assert_equal(ip, IpGeolocation.find_or_lookup!("45.83.91.1", max_age: 7.days))
        assert_equal("New", ip.reload.city)
        assert_in_delta(Time.zone.now, ip.checked_at, 1.minute)
      end

      should "look up the IP again if it has never been checked" do
        ip = create(:ip_geolocation, ip_addr: "45.83.91.1", city: "Old", checked_at: nil)
        mock_ipregistry("45.83.91.1", location: { city: "New" })

        IpGeolocation.find_or_lookup!("45.83.91.1")

        assert_equal("New", ip.reload.city)
      end

      should "return the old record when looking up the IP again fails" do
        ip = create(:ip_geolocation, ip_addr: "45.83.91.1", city: "Old", checked_at: 30.days.ago)
        mock_ipregistry("45.83.91.1", status: 429, code: "TOO_MANY_REQUESTS")

        assert_equal(ip, IpGeolocation.find_or_lookup!("45.83.91.1"))
        assert_equal("Old", ip.reload.city)
        assert_in_delta(30.days.ago, ip.checked_at, 1.minute)
      end

      should "return nothing when the lookup fails and the IP hasn't been seen before" do
        mock_ipregistry("45.83.91.1", status: 429, code: "TOO_MANY_REQUESTS")

        assert_no_difference("IpGeolocation.count") do
          assert_nil(IpGeolocation.find_or_lookup!("45.83.91.1"))
        end
      end

      should "return the old record and log the error when saving the looked up IP fails" do
        ip = create(:ip_geolocation, ip_addr: "45.83.91.1", city: "Old", checked_at: 30.days.ago)
        mock_ipregistry("45.83.91.1", location: { city: "New\u0000" })
        DanbooruLogger.expects(:log).once

        assert_equal(ip, IpGeolocation.find_or_lookup!("45.83.91.1"))
        assert_equal("Old", ip.reload.city)
        assert_in_delta(30.days.ago, ip.checked_at, 1.minute)
      end

      should "not break the surrounding transaction when the database rejects the response" do
        ip = create(:ip_geolocation, ip_addr: "45.83.91.1", city: "Old", checked_at: 30.days.ago)
        mock_ipregistry("45.83.91.1", hostname: "bad\u0000host", location: { city: "New" })
        DanbooruLogger.expects(:log).once

        assert_equal(ip, IpGeolocation.find_or_lookup!("45.83.91.1"))
        assert_equal("Old", ip.reload.city)
      end

      should "return nothing and log the error when the provider's response is malformed" do
        mock_ipregistry("45.83.91.1", location: "Paris")
        DanbooruLogger.expects(:log).once

        assert_no_difference("IpGeolocation.count") do
          assert_nil(IpGeolocation.find_or_lookup!("45.83.91.1"))
        end
      end

      should "return nothing for local IPs" do
        Danbooru::Http.any_instance.expects(:get).never

        assert_nil(IpGeolocation.find_or_lookup!("127.0.0.1"))
        assert_nil(IpGeolocation.find_or_lookup!("10.0.0.1"))
      end

      should "return nothing when no provider is configured" do
        Danbooru.config.stubs(:ip_intelligence_provider).returns(nil)

        assert_nil(IpGeolocation.find_or_lookup!("45.83.91.1"))
      end
    end

    context "the lookup! method" do
      setup do
        Danbooru.config.stubs(:ip_intelligence_provider).returns("ipregistry://ipregistry-key")
      end

      # This happens when two requests look up the same new IP at the same time, and the other request saves it first.
      should "update the existing record instead of creating a duplicate if the IP was already saved" do
        ip = create(:ip_geolocation, ip_addr: "45.83.91.1", city: "Old", ip_type: "isp", created_at: 30.days.ago, checked_at: 30.days.ago)
        mock_ipregistry("45.83.91.1", location: { city: "New" }, security: { is_vpn: true })

        new_ip = assert_no_difference("IpGeolocation.count") { IpGeolocation.lookup!("45.83.91.1") }

        assert_equal(ip.id, new_ip.id)
        assert_equal("New", new_ip.city)
        assert_equal("vpn", new_ip.ip_type)
        assert_in_delta(Time.zone.now, new_ip.checked_at, 1.minute)
        assert_in_delta(30.days.ago, new_ip.created_at, 1.minute)
        assert_in_delta(Time.zone.now, new_ip.updated_at, 1.minute)
      end

      should "save the provider's attributes for a new IP" do
        mock_ipregistry("45.83.91.1", connection: { route: "45.83.91.0/24", type: "hosting" }, location: { city: "Ashburn" })

        ip = assert_difference("IpGeolocation.count", 1) { IpGeolocation.lookup!("45.83.91.1") }

        assert_equal("45.83.91.1", ip.ip_addr.to_s)
        assert_equal("45.83.91.0/24", ip.network.to_s)
        assert_equal("ipregistry", ip.provider)
        assert_equal("hosting", ip.ip_type)
        assert_equal("Ashburn", ip.city)
        assert_equal("hosting", ip.response.dig("connection", "type"))
      end

      should "return nothing when the lookup fails" do
        mock_ipregistry("45.83.91.1", status: 429, code: "TOO_MANY_REQUESTS")

        assert_no_difference("IpGeolocation.count") do
          assert_nil(IpGeolocation.lookup!("45.83.91.1"))
        end
      end

      should "not look up local or Tor IPs" do
        Danbooru::Http.any_instance.expects(:get).never

        assert_nil(IpGeolocation.lookup!("127.0.0.1"))
        assert_nil(IpGeolocation.lookup!("fe80::1"))
        assert_nil(IpGeolocation.lookup!("2405:8100:8000::1"))
      end
    end

    context "Danbooru::IpAddress#is_proxy?" do
      setup do
        Danbooru.config.stubs(:ip_intelligence_provider).returns("ipregistry://ipregistry-key")
      end

      should "use the saved IP information" do
        create(:ip_geolocation, ip_addr: "45.83.91.1", is_proxy: true, checked_at: 1.day.ago)
        create(:ip_geolocation, ip_addr: "45.83.91.2", is_proxy: false, checked_at: 1.day.ago)
        Danbooru::Http.any_instance.expects(:get).never

        assert_equal(true, Danbooru::IpAddress.new("45.83.91.1").is_proxy?)
        assert_equal(false, Danbooru::IpAddress.new("45.83.91.2").is_proxy?)
      end

      should "be true for Tor IPs and false for local IPs" do
        Danbooru::Http.any_instance.expects(:get).never

        assert_equal(true, Danbooru::IpAddress.new("2405:8100:8000::1").is_proxy?)
        assert_equal(false, Danbooru::IpAddress.new("127.0.0.1").is_proxy?)
      end

      should "be false when the IP can't be looked up" do
        mock_ipregistry("45.83.91.1", status: 500)

        assert_equal(false, Danbooru::IpAddress.new("45.83.91.1").is_proxy?)
      end

      should "use the old saved information when looking up the IP again raises an error" do
        create(:ip_geolocation, ip_addr: "45.83.91.1", is_proxy: true, checked_at: 30.days.ago)
        mock_ipregistry("45.83.91.1", location: "Paris")

        assert_equal(true, Danbooru::IpAddress.new("45.83.91.1").is_proxy?)
      end
    end

    context "the lookup! method with the live IPRegistry API" do
      setup do
        skip "IPRegistry credentials not configured" unless IpIntelligence.for("1.1.1.1").is_a?(IpIntelligence::IpRegistry)
      end

      should "create a new record if the IP record doesn't already exist" do
        assert_difference("IpGeolocation.count", 1) do
          IpGeolocation.lookup!("1.1.1.1")
        end
      end

      should "update an existing record if the IP record already exists" do
        @ip1 = IpGeolocation.lookup!("1.1.1.1")
        @ip1.update(asn: -1)
        @ip2 = IpGeolocation.lookup!("1.1.1.1")

        assert_equal(1, IpGeolocation.count)
        assert_equal(@ip1.id, @ip2.id)
        assert_equal(13_335, @ip1.reload.asn)
      end

      should "return nothing for an invalid IP" do
        assert_nil(IpGeolocation.lookup!("0.0.0.0"))
      end

      should "return nothing for a local IP" do
        assert_nil(IpGeolocation.lookup!("127.0.0.1"))
        assert_nil(IpGeolocation.lookup!("10.0.0.1"))
        assert_nil(IpGeolocation.lookup!("fe80::1"))
        assert_nil(IpGeolocation.lookup!("::1"))
      end

      should "work for a residential IP" do
        @ip = IpGeolocation.lookup!("2a01:0e35:2f22:e3d0::1")

        assert_equal(28, @ip.network.prefix)
        assert_equal(false, @ip.is_proxy?)
        # assert_equal(44, @ip.latitude.round(0))
        # assert_equal(4, @ip.longitude.round(0))
        assert_equal("Free SAS", @ip.organization)
        assert_equal("Europe/Paris", @ip.time_zone)
        assert_equal("EU", @ip.continent)
        assert_equal("FR", @ip.country)
        # assert_equal("FR-OCC", @ip.region)
        # assert_equal("Argenteuil", @ip.city)
        assert_equal("Free", @ip.carrier)
      end

      should "work for a mobile IP" do
        @ip = IpGeolocation.lookup!("37.173.153.166")
        assert_match(/Free/, @ip.carrier)
      end

      should "work for a proxy IP" do
        @ip = IpGeolocation.lookup!("202.40.177.186")
        assert_match(/Ranks Itt/i, @ip.organization)
        assert_equal(true, @ip.is_proxy?)
      end

      should "work for a cloud hosting IP" do
        @ip = IpGeolocation.lookup!("157.230.244.215")
        assert_match(/DigitalOcean, LLC/i, @ip.organization)
        assert_equal(true, @ip.is_proxy?)
      end

      should "work for a bogon IP" do
        @ip = IpGeolocation.lookup!("198.51.100.1")
        assert_nil(@ip.ip_type)
        assert_equal(false, @ip.is_proxy?)
      end
    end
  end
end
