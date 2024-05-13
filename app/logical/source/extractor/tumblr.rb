# frozen_string_literal: true

# @see Source::URL::Tumblr
class Source::Extractor
  class Tumblr < Source::Extractor
    def self.enabled?
      Danbooru.config.tumblr_consumer_key.present?
    end

    def image_urls
      return [find_largest(parsed_url)].compact if parsed_url.image_url?

      assets = []

      case post[:type]
      when "photo"
        assets += post[:photos].map do |photo|
          sizes = [photo[:original_size]] + photo[:alt_sizes]
          biggest = sizes.max_by { |x| x[:width] * x[:height] }
          biggest[:url]
        end

      when "video"
        assets += [post[:video_url]].compact_blank
      end

      assets += inline_media
      assets = assets.map { |url| find_largest(url) }
      assets.compact
    end

    def page_url
      "https://#{artist_name}.tumblr.com/post/#{work_id}" if artist_name.present? && work_id.present?
    end

    def profile_url
      "https://#{artist_name}.tumblr.com" if artist_name.present?
    end

    def artist_commentary_title
      case post[:type]
      when "text", "link"
        post[:title]

      else
        nil
      end
    end

    def artist_commentary_desc
      case post[:type]
      when "text"
        post[:body]

      when "link"
        post[:description]

      when "photo", "video"
        post[:caption]

      when "answer"
        post[:answer]

      else
        nil
      end
    end

    def tags
      post[:tags].to_a.map do |tag|
        [tag, "https://tumblr.com/tagged/#{Danbooru::URL.escape(tag)}"]
      end.uniq
    end

    def normalize_tag(tag)
      tag = tag.tr("-", "_")
      super(tag)
    end

    # The commentary with reblogs presented as a linear list of quotes, rather than as nested quotes.
    def linear_artist_commentary_desc
      return artist_commentary_desc if post[:trail].blank?

      post[:trail].to_a.map do |item|
        post_url = "https://#{item.dig(:blog, :name)}.tumblr.com/post/#{item.dig(:post, :id)}"

        # Hack to forcibly escape raw quotes inside alt text. Necessary because Tumblr incorrectly doesn't escape quote
        # marks inside alt text in the `content_raw` attribute.
        content = item[:content_raw].gsub(/alt="(.*?)" srcset=/) { %{alt="#{$1.gsub('"', "&quot;")}" srcset=} }

        # https://www.tumblr.com/noizave/171237880542/test-ask
        if item[:is_root_item] && item[:is_current_item] && post[:type] == "answer"
          <<~EOS.chomp
            <blockquote>
              <p>#{post[:asking_name]} asked:</p>

              #{post[:question]}
            </blockquote>

            #{content}
          EOS
        # https://www.tumblr.com/shortgremlinman/707877745599905792/get-asked-idiot
        elsif item[:is_root_item] && !item[:is_current_item] && post[:type] == "answer"
          <<~EOS.chomp
            <blockquote>
              <p>#{post[:asking_name]} asked:</p>

              #{post[:question]}
            </blockquote>

            <blockquote>
              <p><a href="#{post_url}">#{item.dig(:blog, :name)}</a> answered:</p>

              #{content}
            </blockquote>
          EOS
        elsif item[:is_current_item]
          content
        else
          <<~EOS.chomp
            <blockquote>
              <p><a href="#{post_url}">#{item.dig(:blog, :name)}</a>:</p>

              #{content}
            </blockquote>
          EOS
        end
      end.join
    end

    def dtext_artist_commentary_desc
      DText.from_html(linear_artist_commentary_desc, base_url: "https://www.tumblr.com") do |element|
        case element.name
        # https://tmblr.co/m08AoE-xy5kbQnjed6Tcmng -> https://www.tumblr.com/phantom-miria
        in "a" if Source::URL.parse(element["href"])&.domain == "tmblr.co"
          element["href"] = Source::Extractor::URLShortener.new(element["href"]).redirect_url || element["href"]

        # <a href="https://www.tumblr.com/blog/view/professionalchaoticdumbass/707743740292382721" class="poll-row"><p>idiot.</p></a>
        in "a" if element[:class] == "poll-row"
          element.name = "li"

        # <a href="https://www.tumblr.com/blog/view/professionalchaoticdumbass/707743740292382721">See Results</a><
        in "a" if element.text == "See Results" && element.parent&.css(".poll-question").present?
          element.content = nil

        # <span class="tmblr-alt-text-helper">ALT</span>
        in "span" if element["class"] == "tmblr-alt-text-helper"
          element.content = nil

        # https://localapparently.tumblr.com/post/744819709718003712
        in "img" if element["alt"].present? && element.next&.attr(:class) == "tmblr-alt-text-helper"
          element.name = "blockquote"
          element.inner_html = <<~EOS
            <h6>Image description</h6>

            <p>#{CGI.escapeHTML(element["alt"]).gsub(/\n\n+/, "<p>")}</p>
          EOS

        # Include images inside quotes to provide context for responses.
        in "img" if element.ancestors.any? { |e| e.name == "blockquote" }
          element.name = "p"
          element.inner_html = %{<a href="#{element[:src]}">[image]</a>}

        # Skip images that don't have alt text or that aren't inside quotes
        in "img"
          element.name = "span"

        in "text" if element.text.strip == "[[MORE]]"
          element.content = nil

        else
          nil
        end
      end
    end

    def find_largest(image_url)
      parsed_image = Source::URL.parse(image_url)
      if parsed_image.full_image_url.present?
        image_url_html(parsed_image.full_image_url)&.at("img[src*='/#{parsed_image.directory}/']")&.[](:src)
      elsif parsed_image.variants.present?
        # Look for the biggest available version on media.tumblr.com. A bigger version may or may not exist.
        parsed_image.variants.find { |variant| http_exists?(variant) } || image_url
      else
        parsed_image.original_url
      end
    end

    memoize def post_url_from_image_html
      # https://at.tumblr.com/everythingfox/everythingfox-so-sleepy/d842mqsx8lwd
      if parsed_url.subdomain == "at"
        response = http.get(parsed_url)
        return nil if response.status != 200

        url = Source::URL.parse(response.request.uri)
        url if url.page_url?
      elsif parsed_url.image_url? && parsed_url.file_ext&.in?(%w[jpg png pnj gif])
        # https://compllege.tumblr.com/post/179415753146/codl-0001-c-experiment-2018%E5%B9%B410%E6%9C%8828%E6%97%A5-m3
        # https://yra.sixc.me/post/188271069189
        post_url = image_url_html(parsed_url)&.at('meta[name="parsely-link"]')&.attr(:content)
        return nil if post_url.blank?

        # The post URL may be a regular Tumblr post or a custom domain; custom domains are extracted to get the real Tumblr page URL.
        Source::Extractor.find(post_url).page_url.then { Source::URL.parse(_1) }
      end
    end

    def image_url_html(image_url)
      resp = http.cache(1.minute).headers(accept: "text/html").get(image_url)
      return nil if resp.code != 200 || resp.mime_type != "text/html"
      resp.parse
    end

    memoize def inline_media
      # If this post is a reblog, only include images from it, not from the parent post(s).
      comment = post[:parent_post_url].present? ? post.dig(:reblog, :comment) : artist_commentary_desc
      comment.to_s.parse_html.css("img, video source").pluck(:src)
    end

    def artist_name
      parsed_url.blog_name || parsed_referer&.blog_name || post_url_from_image_html&.try(:blog_name) # Don't crash with custom domains
    end

    memoize def work_id
      parsed_url.work_id || parsed_referer&.work_id || post_url_from_image_html&.try(:work_id)
    end

    memoize def api_response
      return {} unless self.class.enabled?
      return {} unless artist_name.present? && work_id.present?

      params = { id: work_id, api_key: Danbooru.config.tumblr_consumer_key }
      http.cache(1.minute).parsed_get("https://api.tumblr.com/v2/blog/#{artist_name}/posts", params: params) || {}
    end

    def post
      api_response.dig(:response, :posts)&.first || {}
    end
  end
end
