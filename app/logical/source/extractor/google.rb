# frozen_string_literal: true

# This handles *.ggpht.com and lh*.googleusercontent.com image URLs used by Youtube, Blogger, and other Google services.
# We can't tell which extractor to use based on the URL itself, but if the referer URL is present we can use it to
# delegate to the real extractor.
#
# @see Source::URL::Google
class Source::Extractor::Google < Source::Extractor
  delegate :page_url, :profile_url, :artist_name, :display_name, :username, :tag_name, :artist_commentary_title, :artist_commentary_desc, :dtext_artist_commentary_title, :dtext_artist_commentary_desc, to: :sub_extractor, allow_nil: true

  # Don't ignore the referer URL when it's from a different site (Youtube, Blogger, Opensea, etc).
  def allow_referer?
    true
  end

  def image_urls
    if sub_extractor.present?
      sub_extractor.image_urls
    elsif parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif parsed_url.image_url?
      [parsed_url.image_url]
    else
      []
    end
  end

  def other_names
    sub_extractor&.other_names || []
  end

  def profile_urls
    sub_extractor&.profile_urls || []
  end

  def tags
    sub_extractor&.tags || []
  end

  def artists
    sub_extractor&.artists || []
  end

  memoize def sub_extractor
    parsed_referer&.extractor_class&.new(parsed_url, referer_url: parsed_referer, parent_extractor: self)
  end
end
