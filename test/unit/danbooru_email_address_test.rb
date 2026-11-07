require "test_helper"

class DanbooruEmailAddressTest < ActiveSupport::TestCase
  def assert_undeliverable(expected, address)
    Danbooru::EmailAddress.any_instance.stubs(:delivery_enabled?).returns(true)
    assert_equal(expected, Danbooru::EmailAddress.new(address).undeliverable?)
  end

  context "Danbooru::EmailAddress" do
    context "#undeliverable?" do
      should "return good addresses as deliverable" do
        assert_undeliverable(false, "webmaster@danbooru.donmai.us")
        assert_undeliverable(false, "noizave+spam@gmail.com")
      end

      should "return nonexistent domains as undeliverable" do
        assert_undeliverable(true, "nobody@does.not.exist.donmai.us")
      end

      context "when the MX record points to a local IP" do
        setup do
          Danbooru::EmailAddress.any_instance.stubs(:smtp_enabled?).returns(true)
          Danbooru::EmailAddress.any_instance.stubs(:mx_domain).returns("smtp.attacker.example")
        end

        %w[127.0.0.1 169.254.169.254 10.0.0.1 192.168.1.1 0.0.0.0 192.0.0.192 ::1 ::ffff:169.254.169.254 ::7f00:1 2002:a9fe:a9fe::1 64:ff9b::a9fe:a9fe 2001:0:4136:e378:8000:63bf:3fff:fdd2].each do |ip|
          should "not connect to #{ip}" do
            resolved_ip = ip.include?(":") ? Resolv::IPv6.create(ip) : Resolv::IPv4.create(ip)
            Resolv::DNS.any_instance.stubs(:getaddress).with("smtp.attacker.example").returns(resolved_ip)
            Net::SMTP.expects(:new).never

            assert_equal(true, Danbooru::EmailAddress.new("foo@attacker.example").undeliverable?)
          end
        end
      end

      should "connect to the resolved IP of a public MX server" do
        Danbooru::EmailAddress.any_instance.stubs(:smtp_enabled?).returns(true)
        Danbooru::EmailAddress.any_instance.stubs(:mx_domain).returns("smtp.example.com")
        Resolv::DNS.any_instance.stubs(:getaddress).with("smtp.example.com").returns(Resolv::IPv4.create("93.184.215.14"))
        Net::SMTP.expects(:new).with("93.184.215.14", tls_hostname: "smtp.example.com").raises(Net::OpenTimeout)

        assert_equal(false, Danbooru::EmailAddress.new("foo@example.com").undeliverable?)
      end

      # XXX these tests are known to fail if your network blocks port 25.
      should_eventually "return nonexistent addresses as undeliverable" do
        assert_undeliverable(true, "does.not.exist.13yoigo34iy@gmail.com")
        assert_undeliverable(true, "does.not.exist.13yoigo34iy@outlook.com")
        assert_undeliverable(true, "does.not.exist.13yoigo34iy@hotmail.com")
      end
    end
  end
end
