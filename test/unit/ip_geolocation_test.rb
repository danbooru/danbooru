require 'test_helper'

class IpGeolocationTest < ActiveSupport::TestCase
  setup do
    skip "IP Registry credentials not configured" unless IpLookup.enabled?
  end

  context "IpGeolocation: " do
    context "the create_or_update! method" do
      should "create a new record if the IP record doesn't already exist" do
        assert_difference("IpGeolocation.count", 1) do
          IpGeolocation.create_or_update!("1.1.1.1")
        end
      end

      should "update an existing record if the IP record already exists" do
        @ip1 = IpGeolocation.create_or_update!("1.1.1.1")
        @ip1.update(asn: -1)
        @ip2 = IpGeolocation.create_or_update!("1.1.1.1")

        assert_equal(1, IpGeolocation.count)
        assert_equal(@ip1.id, @ip2.id)
        assert_equal(13335, @ip1.reload.asn)
      end

      should "return nothing for an invalid IP" do
        assert_nil(IpGeolocation.create_or_update!("0.0.0.0"))
      end

      should "return nothing for a local IP" do
        assert_nil(IpGeolocation.create_or_update!("127.0.0.1"))
        assert_nil(IpGeolocation.create_or_update!("10.0.0.1"))
        assert_nil(IpGeolocation.create_or_update!("fe80::1"))
        assert_nil(IpGeolocation.create_or_update!("::1"))
      end

      should "work for a residential IP" do
        @ip = IpGeolocation.create_or_update!("2a01:0e35:2f22:e3d0::1")

        assert_equal(28, @ip.network.prefix)
        assert_equal(false, @ip.is_proxy?)
        assert_equal(49, @ip.latitude.round(0))
        assert_equal(2, @ip.longitude.round(0))
        assert_equal("Free SAS", @ip.organization)
        assert_equal("Europe/Paris", @ip.time_zone)
        assert_equal("EU", @ip.continent)
        assert_equal("FR", @ip.country)
        assert_equal("FR-IDF", @ip.region)
        #assert_equal("Argenteuil", @ip.city)
        assert_nil(@ip.carrier)
      end

      should "work for a mobile IP" do
        @ip = IpGeolocation.create_or_update!("37.173.153.166")
        assert_equal("Free Mobile", @ip.carrier)
      end

      should "work for a proxy IP" do
        @ip = IpGeolocation.create_or_update!("31.214.184.59")
        assert_equal("Soluciones Corporativas IP SL", @ip.organization)
        assert_equal(true, @ip.is_proxy?)
      end

      should "work for a cloud hosting IP" do
        @ip = IpGeolocation.create_or_update!("157.230.244.215")
        assert_equal("DigitalOcean LLC", @ip.organization)
        assert_equal(true, @ip.is_proxy?)
      end

      should "work for a bogon IP" do
        @ip = IpGeolocation.create_or_update!("103.10.192.0")
        assert_equal(true, @ip.is_proxy?)
      end
    end
  end
end
