# frozen_string_literal: true

# Page URLs:
#
# * https://twitpic.com/dvitq3 (live)
# * https://twitpic.com/9tgik8 (dead)
#
# Image URLs:
#
# # Live. Image for https://twitpic.com/dvitq3. `dvitq3` is base36 for 839006715.
# * https://dn3pm25xmtlyu.cloudfront.net/photos/large/839006715.jpg?Expires=1646850828&Signature=d60CmLlmNqZJvOTteTOan13QWZ8gY3C4rUWCkh-IUoRr012vYtUYtip74GslGwCG0dxV5mpUpVFkaVZf16PiY7CsTdpAlA8Pmu2tN98D2dmC5FuW9KhhygDv6eFC8faoaGEyj~ArLuwz-8lC6Y05TVf0FgweeWwsRxFOfD5JHgCeIB0iZqzUx1t~eb6UMAWvbaKpfgvcp2oaDuCdZlMNi9T5OUBFoTh2DfnGy8t5COys1nOYYfZ9l69TDvVb2PKBaV8lsKK9xMwjoJNaWa1HL5S4MgODS5hiNDvycoBpu9KUvQ7q~rhC8cV6ZNctB5H9u~MmvBPoTKfy4w37cSc5uw__&Key-Pair-Id=APKAJROXZ7FN26MABHYA
#
# # Live. Image for https://twitpic.com/dks0tb.
# * http://d3j5vwomefv46c.cloudfront.net/photos/large/820960031.jpg?1384107199
#
# # Dead. Old images for http://twitpic/dvitq3.
# * https://twitpic.com/show/large/dvitq3.jpg
# * https://o.twimg.com/2/proxy.jpg?t=HBgpaHR0cHM6Ly90d2l0cGljLmNvbS9zaG93L2xhcmdlL2R2aXRxMy5qcGcUsAkUsg0AFgASAA&s=NeY89zVAEpDjLcxZ_8KOoF7VGr2dm1Vc3HIozPy__Ng
#
# Profile URLs:
#
# * http://twitpic.com/photos/Type10TK (dead)

class Source::URL::TwitPic < Source::URL
  attr_reader :base36_id, :username

  def self.match?(url)
    url.host.in?(%w[twitpic.com o.twimg.com dn3pm25xmtlyu.cloudfront.net d3j5vwomefv46c.cloudfront.net])
  end

  def site_name
    "TwitPic"
  end

  def parse
    case [domain, *path_segments]

    # https://twitpic.com/carwkf
    in "twitpic.com", base36_id
      @base36_id = base36_id

    # https://twitpic.com/show/large/carwkf.jpg
    in "twitpic.com", "show", size, _
      @base36_id = filename

    # http://twitpic.com/photos/Type10TK (dead)
    in "twitpic.com", "photos", username
      @username = username

    # https://o.twimg.com/1/proxy.jpg?t=FQQVBBgpaHR0cHM6Ly90d2l0cGljLmNvbS9zaG93L2xhcmdlL2NhcndrZi5qcGcUBBYAEgA&s=y8haxddqxJYpWql9uVnP3aoFFS7rA10vOGPdTO5HXvk
    # https://o.twimg.com/2/proxy.jpg?t=HBgpaHR0cHM6Ly90d2l0cGljLmNvbS9zaG93L2xhcmdlL2R0bnVydS5qcGcUsAkU0ggAFgASAA&s=dnN4DHCdnojC-iCJWdvZ-UZinrlWqAP7k7lmll2fTxs
    in "twimg.com", subdir, "proxy.jpg" if params[:t].present?
      # FQQVBBgpaHR0cHM6Ly90d2l0cGljLmNvbS9zaG93L2xhcmdlL2NhcndrZi5qcGcUBBYAEgA
      @base64_id = params[:t]

      # "\x15\x04\x15\x04\x18)https://twitpic.com/show/large/carwkf.jpg\x14\x04\x16\x00\x12\x00"
      @decoded_base64_id = Base64.decode64(@base64_id)

      # https://twitpic.com/show/large/carwkf.jpg
      @decoded_url = URI.extract(@decoded_base64_id, %w[http https]).first

      # carwkf
      @base36_id = Source::URL.parse(@decoded_url).base36_id if @decoded_url.present?

    # http://d3j5vwomefv46c.cloudfront.net/photos/large/820960031.jpg?1384107199
    # https://dn3pm25xmtlyu.cloudfront.net/photos/large/839006715.jpg?Expires=1646850828&Signature=d60CmLlmNqZJvOTteTOan13QWZ8gY3C4rUWCkh-IUoRr012vYtUYtip74GslGwCG0dxV5mpUpVFkaVZf16PiY7CsTdpAlA8Pmu2tN98D2dmC5FuW9KhhygDv6eFC8faoaGEyj~ArLuwz-8lC6Y05TVf0FgweeWwsRxFOfD5JHgCeIB0iZqzUx1t~eb6UMAWvbaKpfgvcp2oaDuCdZlMNi9T5OUBFoTh2DfnGy8t5COys1nOYYfZ9l69TDvVb2PKBaV8lsKK9xMwjoJNaWa1HL5S4MgODS5hiNDvycoBpu9KUvQ7q~rhC8cV6ZNctB5H9u~MmvBPoTKfy4w37cSc5uw__&Key-Pair-Id=APKAJROXZ7FN26MABHYA
    in /cloudfront\.net/, "photos", size, _
      @base36_id = filename.to_i.to_s(36)

    else
      nil
    end
  end

  def page_url
    "https://twitpic.com/#{base36_id}" if base36_id.present?
  end

  def profile_url
    "http://twitpic.com/photos/#{username}" if username.present?
  end
end
