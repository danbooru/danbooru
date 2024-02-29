require 'test_helper'

class DanbooruDomainTest < ActiveSupport::TestCase
  def parse(domain)
    Danbooru::Domain.parse(domain)
  end

  context "Danbooru::Domain" do
    context "#parse method" do
      should "parse the domain" do
        assert_not_nil(parse("www.google.com"))
        assert_not_nil(parse("localhost"))
        assert_not_nil(parse("bücher.example"))
        assert_not_nil(parse("😭.ws"))
        assert_not_nil(parse("яндекс.рф"))
        assert_not_nil(parse("小度.中国"))
        assert_not_nil(parse("hosi_na.artstation.com"))
        assert_not_nil(parse("arisaka_.web.fc2.com"))

        assert_nil(parse(""))
        assert_nil(parse("."))
        assert_nil(parse("google..com"))
        assert_nil(parse(".google.com"))
        assert_nil(parse("#{"x" * 64}.com"))
        assert_nil(parse("#{4.times.map { "x" * 63 }.join(".")}.com"))

        assert_nil(parse("google.123"))
        assert_nil(parse("google.c-m"))
        assert_nil(parse("google.com-"))
        assert_nil(parse("google.-com"))
        assert_nil(parse("google.x"))
        assert_nil(parse("google-.com"))
        assert_nil(parse("-google.com"))
        assert_nil(parse("google!.com"))
        assert_nil(parse("goo_gle.com"))
        assert_nil(parse("foo@google.com"))
      end
    end

    context "#normalized_domain method" do
      should "normalize the domain" do
        assert_equal("www.google.com", parse("www.google.com").normalized_domain)
        assert_equal("www.google.com", parse("WWW.GOOGLE.COM.").normalized_domain)
      end
    end

    context "#domain method" do
      should "return the domain" do
        assert_equal("google.com", parse("www.google.com").domain)
        assert_equal("google.com", parse("www.google.com.").domain)
        assert_equal("google.com", parse("WWW.GOOGLE.COM").domain)
        assert_equal("google.com", parse("google.com").domain)
        assert_equal("google.co.uk", parse("www.google.co.uk").domain)
        assert_equal("google.co.uk", parse("google.co.uk").domain)

        assert_equal("amazonaws.com", parse("blah.s3.amazonaws.com").domain)
        assert_equal("cloudfront.net", parse("blah.cloudfront.net").domain)
        assert_equal("city.shibuya.tokyo.jp", parse("www.lib.city.shibuya.tokyo.jp").domain)

        assert_equal("com", parse("com").domain)
        assert_equal("co.uk", parse("co.uk").domain)
        assert_equal("localhost", parse("localhost").domain)
      end
    end

    context "#subdomain method" do
      should "return the subdomain" do
        assert_equal("www", parse("www.google.com").subdomain)
        assert_equal("www", parse("www.google.com.").subdomain)
        assert_equal("www", parse("WWW.google.com").subdomain)
        assert_equal("www", parse("www.google.co.uk").subdomain)

        assert_equal("hosi_na", parse("hosi_na.artstation.com").subdomain)
        assert_equal("blah.s3", parse("blah.s3.amazonaws.com").subdomain)
        assert_equal("blah", parse("blah.cloudfront.net").subdomain)
        assert_equal("www.lib", parse("www.lib.city.shibuya.tokyo.jp").subdomain)

        assert_nil(parse("google.com").subdomain)
        assert_nil(parse("google.com.").subdomain)
        assert_nil(parse("google.co.uk").subdomain)
        assert_nil(parse("localhost").subdomain)
        assert_nil(parse("co.uk").subdomain)
      end
    end

    context "#sld method" do
      should "return the SLD" do
        assert_equal("google", parse("www.google.com").sld)
        assert_equal("google", parse("www.google.com.").sld)
        assert_equal("google", parse("WWW.GOOGLE.COM").sld)
        assert_equal("google", parse("google.com").sld)
        assert_equal("google", parse("www.google.co.uk").sld)
        assert_equal("google", parse("google.co.uk").sld)

        assert_equal("amazonaws", parse("blah.s3.amazonaws.com").sld)
        assert_equal("cloudfront", parse("blah.cloudfront.net").sld)
        assert_equal("city", parse("www.lib.city.shibuya.tokyo.jp").sld)

        assert_equal("co", parse("co.uk").sld)
        assert_equal("localhost", parse("localhost").sld)
      end
    end

    context "#etld method" do
      should "return the eTLD" do
        assert_equal("com", parse("www.google.com").etld)
        assert_equal("com", parse("www.google.com.").etld)
        assert_equal("com", parse("WWW.GOOGLE.COM").etld)
        assert_equal("co.uk", parse("www.google.co.uk").etld)

        assert_equal("com", parse("blah.s3.amazonaws.com").etld)
        assert_equal("net", parse("blah.cloudfront.net").etld)
        assert_equal("shibuya.tokyo.jp", parse("www.lib.city.shibuya.tokyo.jp").etld)

        assert_equal("uk", parse("co.uk").etld)
        assert_nil(parse("localhost").etld)
      end
    end

    context "#tld method" do
      should "return the TLD" do
        assert_equal("com", parse("www.google.com").tld)
        assert_equal("com", parse("www.google.com.").tld)
        assert_equal("com", parse("WWW.GOOGLE.COM").tld)

        assert_equal("uk", parse("www.google.co.uk").tld)
        assert_equal("uk", parse("co.uk").tld)

        assert_equal("com", parse("blah.s3.amazonaws.com").tld)
        assert_equal("net", parse("blah.cloudfront.net").tld)
        assert_equal("jp", parse("www.lib.city.shibuya.tokyo.jp").tld)

        assert_nil(parse("localhost").tld)
        assert_nil(parse("uk").tld)
      end
    end

    context "#dotless? method" do
      should "work" do
        assert_equal(false, parse("www.google.com").dotless?)
        assert_equal(false, parse("co.uk").dotless?)
        assert_equal(true, parse("localhost").dotless?)
        assert_equal(true, parse("com").dotless?)
        assert_equal(true, parse("com.").dotless?)
      end
    end
  end
end
