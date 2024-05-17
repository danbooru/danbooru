# frozen_string_literal: true

module Source
  class Extractor
    class DeviantArt < Source::Extractor
      def self.enabled?
        Danbooru.config.deviantart_client_id.present? && Danbooru.config.deviantart_client_secret.present?
      end

      def image_urls
        [image_url].compact
      end

      def image_url
        if download_url.present?
          download_url
        elsif sample_image_url.present?
          sample_image_url
        elsif parsed_url.full_image_url.present?
          parsed_url.full_image_url
        elsif parsed_url.image_url?
          # Convert old image URLs to new wixmp.com URLs. Used when the work is deleted and we can't get a better URL.
          #
          # http://pre06.deviantart.net/8497/th/pre/f/2009/173/c/c/cc9686111dcffffffb5fcfaf0cf069fb.jpg
          # => https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg/v1/fill/w_786,h_1017,q_75,strp/cc9686111dcffffffb5fcfaf0cf069fb.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwic3ViIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImF1ZCI6WyJ1cm46c2VydmljZTppbWFnZS5vcGVyYXRpb25zIl0sIm9iaiI6W1t7InBhdGgiOiIvZi84YjQ3MmQ3MC1hMGQ2LTQxYjUtOWE2Ni1jMzU2ODcwOTBhY2MvZDIzamJyNC04YTA2YWYwMi03MGNiLTQ2ZGEtOGE5Ni00MmE2YmE3M2NkYjQuanBnIiwid2lkdGgiOiI8PTc4NiIsImhlaWdodCI6Ijw9MTAxNyJ9XV19.EXlDqS_4kMSDO26RTsuqE-H_XI0xSiO3dnAQRV6puqw
          # => https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg
          url = http.cache(1.minute).redirect_url(parsed_url)&.then { |url| Source::URL.parse(url) }
          url&.full_image_url || url.to_s
        end
      end

      # Get the best possible sample URL based on the width/height restrictions in the sample token.
      def sample_image_url
        base_url = deviation.dig("media", "baseUri")

        if subscribers_only? || premium_only?
          nil
        elsif base_url.present? && sample_token.present?
          # https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/654817c0-5ba7-4591-9fd7-badae289cf88/d2wq7wl-b7f18546-753e-4d53-8051-ddb1879776c2.jpg/v1/fit/w_700,h_543,q_70,strp/pkmn_king_and_queen_by_mikotoazure_d2wq7wl-375w-2x.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7ImhlaWdodCI6Ijw9NTQzIiwicGF0aCI6IlwvZlwvNjU0ODE3YzAtNWJhNy00NTkxLTlmZDctYmFkYWUyODljZjg4XC9kMndxN3dsLWI3ZjE4NTQ2LTc1M2UtNGQ1My04MDUxLWRkYjE4Nzk3NzZjMi5qcGciLCJ3aWR0aCI6Ijw9NzAwIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmltYWdlLm9wZXJhdGlvbnMiXX0.5YNpOk20V15EU44A7t_q_rQ_azwfLbsC32-hYgho39E
          # => https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/654817c0-5ba7-4591-9fd7-badae289cf88/d2wq7wl-b7f18546-753e-4d53-8051-ddb1879776c2.jpg/v1/fill/w_700,h_543/pkmn_king_and_queen_by_mikotoazure_d2wq7wl.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7ImhlaWdodCI6Ijw9NTQzIiwicGF0aCI6IlwvZlwvNjU0ODE3YzAtNWJhNy00NTkxLTlmZDctYmFkYWUyODljZjg4XC9kMndxN3dsLWI3ZjE4NTQ2LTc1M2UtNGQ1My04MDUxLWRkYjE4Nzk3NzZjMi5qcGciLCJ3aWR0aCI6Ijw9NzAwIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmltYWdlLm9wZXJhdGlvbnMiXX0.5YNpOk20V15EU44A7t_q_rQ_azwfLbsC32-hYgho39E
          pretty_name = deviation.dig("media", "prettyName")
          v1_path = deviation.dig("media", "types").pick("c").gsub(/<prettyName>[^.]*/, pretty_name)
          url = "#{base_url}#{v1_path}?token=#{sample_token}"

          Source::URL::DeviantArt.parse(url)&.full_image_url
        elsif api_deviation.dig("content", "src").present? # for sta.sh posts
          url = api_deviation.dig("content", "src")
          Source::URL::DeviantArt.parse(url)&.full_image_url
        end
      end

      # Get the download image URL if the work is downloadable.
      def download_url
        # Some deviations have a download token in the metadata. This is better than the download URL from the API
        # because it doesn't require an extra API call and it never expires.
        if download_token.present? && deviation.dig("media", "baseUri").present?
          base_url = deviation.dig("media", "baseUri")
          pretty_name = deviation.dig("media", "prettyName")
          file_ext = base_url.split(".").last
          "#{base_url}?token=#{download_token}&filename=#{pretty_name}.#{file_ext}"
        elsif deviation_extended.dig("download", "url").present?
          # # XXX The download url can also be obtained this way, but it requires a login and an auth cookie.
          # url = deviation_extended.dig("download", "url")      # => https://www.deviantart.com/download/1009941765/dgpak1x-43de07ea-842f-4feb-96eb-5fddb8f96c58.png?token=af97e8685c538f7845bd38a0a2e66f7099c4a35b&ts=1709417243
          # http.cache(1.minute).redirect_url(url).to_s.presence # => https://wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/618b1383-fa36-43cf-a5ef-dbcc45695591/dgpak1x-43de07ea-842f-4feb-96eb-5fddb8f96c58.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImV4cCI6MTcwOTQxNzI2NywiaWF0IjoxNzA5NDE2NjU3LCJqdGkiOiI2NWUzYTBkYjBmM2JmIiwib2JqIjpbW3sicGF0aCI6IlwvZlwvNjE4YjEzODMtZmEzNi00M2NmLWE1ZWYtZGJjYzQ1Njk1NTkxXC9kZ3BhazF4LTQzZGUwN2VhLTg0MmYtNGZlYi05NmViLTVmZGRiOGY5NmM1OC5wbmcifV1dLCJhdWQiOlsidXJuOnNlcnZpY2U6ZmlsZS5kb3dubG9hZCJdfQ.yO47UCbiKrSi20vueE0JAXg7ZSBvOGm2wzI5Nz3l9S0&filename=emomei_by_sayohyou_dgpak1x.png

          api_download["src"]
        elsif deviation.blank? && api_deviation["is_downloadable"] # for sta.sh posts
          api_download["src"]
        elsif videos.present?
          video = videos.max_by { |video| video["f"] } # max filesize
          video["b"] # https://wixmp-ed30a86b8c4ca887773594c2.wixmp.com/v/mp4/a31dacef-8ae2-4b0d-bb01-9e7d6911ee00/df87as3-0705c583-cd5e-4b20-bec1-8330a0cf4c25.1080p.b5c48cb0b3064fb18a287df270bb487a.mp4
        end
      end

      def videos
        deviation.dig("media", "types").to_a.select { |type| type["t"] == "video" }
      end

      # A token that can be used to download the sample image.
      def sample_token
        deviation.dig("media", "token").to_a.first
      end

      # A token that can be used to download the full image. Not always present.
      def download_token
        deviation.dig("media", "token").to_a.second
      end

      # If true, then this a subscribers-only post (a paid reward).
      # https://www.deviantart.com/team/journal/Subscriptions-Beta-Make-Money-Connect-with-Fans-890005897
      def subscribers_only?
        tier_access = deviation.present? ? deviation["tierAccess"] : api_deviation["tier_access"]
        tier_access == "locked"
      end

      # If true, then this is either a premium gallery (a paid reward) or a watchers-only post.
      # https://www.deviantart.com/team/journal/Create-Exclusive-Content-with-Premium-Galleries-847238532
      def premium_only?
        has_access = deviation.present? ? deviation.dig("premiumFolderData", "hasAccess") : api_deviation.dig("premium_folder_data", "has_access")
        has_access == false
      end

      def page_url
        stash_page || deviation["url"].presence || page_url_from_image_url
      end

      def page_url_from_image_url
        # Old image URLs redirect to new wixmp.com URLs that can be used to get the page URL.
        stash_page || parsed_url.page_url_from_redirect(http.cache(1.minute)) || parsed_referer&.page_url
      end

      # Sta.sh posts have the same image URLs as DeviantArt but different page URLs. We use the Sta.sh page if we have one.
      #
      # Image: https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/83d3eb4d-13e5-4aea-a08f-8d4331d033c4/dcmjs1s-389a7505-142d-4b34-a790-ab4ea1ec9eaa.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcLzgzZDNlYjRkLTEzZTUtNGFlYS1hMDhmLThkNDMzMWQwMzNjNFwvZGNtanMxcy0zODlhNzUwNS0xNDJkLTRiMzQtYTc5MC1hYjRlYTFlYzllYWEucG5nIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.pIddc32BoLpAJt6D8YcRFonoVy9nC8RgROlYwMp3huo
      # Page: https://sta.sh/01pwva4zzf98
      def stash_page
        parsed_url.stash_url || parsed_referer&.stash_url
      end

      def profile_url
        "https://www.deviantart.com/#{username}" if username.present?
      end

      def display_name
        user["username"].presence || api_metadata.dig("author", "username")
      end

      def username
        display_name&.downcase || parsed_url.username || parsed_referer&.username
      end

      def artist_commentary_title
        deviation["title"] || api_metadata["title"]
      end

      def artist_commentary_desc
        if deviation_extended.dig("descriptionText", "html", "type") == "writer"
          deviation_extended.dig("descriptionText", "html", "markup")
        else
          api_metadata["description"]
        end
      end

      def tags
        if deviation_extended.present?
          tags = deviation_extended["tags"].to_a.map do |tag|
            [tag["name"], tag["url"]]
          end
        else # for sta.sh posts
          tags = api_metadata["tags"].to_a.map do |tag|
            [tag["tag_name"], "https://www.deviantart.com/tag/#{Danbooru::URL.escape(tag["tag_name"])}"]
          end
        end

        tags << ["ai-generated", "https://www.deviantart.com/tag/ai"] if deviation["isAiGenerated"]
        tags
      end

      def dtext_artist_commentary_desc
        DText.from_html(artist_commentary_desc, base_url: "https://www.deviantart.com", allowed_shortlinks: ["deviantart"]) do |element|
          case element.name

          # Convert embedded thumbnails of journal posts to 'deviantart #123' links. Strip embedded thumbnails of image posts.
          # Example: https://sa-dui.deviantart.com/art/Commission-Meinos-Kaen-695905927
          in "a" if element["data-sigil"] == "thumb"
            element.name = "span"

            # <a href="https://sa-dui.deviantart.com/journal/About-Commissions-223178193" data-sigil="thumb" class="thumb lit" ...>
            if element.classes.include?("lit")
              deviation_id = element["href"][/-(\d+)\z/, 1].to_i
              element.content = "deviantart ##{deviation_id}"
            else
              element.content = ""
            end

          # Ignore <sub> and <small> tags.
          in "sub" | "small"
            element.name = "div"

          # A large image inside a link.
          in "a" if element.classes.include?("draft-thumb")
            element.name = "p"
            element.inner_html = %{<a href="#{element["href"]}">#{element["href"]}</a>}

          # An external link
          in "a" if element["href"].present?
            element["href"] = element["href"].gsub(%r{\Ahttps?://www\.deviantart\.com/users/outgoing\?}i, "")

          # The WYSIWYG editor uses <span> tags for bold, italic, and underlined text.
          in "span" if element["style"].present?
            element.inner_html = "<u>#{element.inner_html}</u>" if element["style"].include?("text-decoration:underline") && element.parent&.name != "a"
            element.inner_html = "<i>#{element.inner_html}</i>" if element["style"].include?("font-style:italic")
            element.inner_html = "<b>#{element.inner_html}</b>" if element["style"].include?("font-weight:bold")

          # A paragraph in the WYSIWYG editor.
          in "div" if element.classes.intersect?(%w[daeditor-paragraph])
            element.name = "p"

          # An image gallery.
          in "div" if element.classes.intersect?(%w[daeditor-torpedo-grid])
            element.name = "ul"

          # An image in an image gallery.
          in "div" if element.classes.intersect?(%w[daeditor-torpedo-grid-item])
            element.name = "li"

          # A small profile picture linking to someone's profile page.
          in "img" if element.parent&.name == "a" && Source::URL.profile_url?(element.parent["href"])
            element["alt"] = ":#{element["alt"]}:"

          # An embedded emoticon.
          in "img" if element["data-embed-type"] == "emoticon"
            element["alt"] = ":#{element["alt"]}:"

          # Ignore alt text in image links.
          in "img"
            element["alt"] = "[image]"

          # An embedded Youtube video.
          in "iframe"
            element.name = "p"
            element.inner_html = %{<a href="#{element["src"]}">#{element["src"]}</a>}

          # Ignore random commas outside of paragraphs. These are only present when using api_metadata["description"]
          # to get the commentary.
          in "text" if element.parent&.attr("class") == "daeditor-fluid"
            element.content = nil

          else
            nil
          end
        end
      end

      def deviation_id
        parsed_url.work_id || parsed_referer&.work_id
      end

      memoize def page
        http.cache(1.minute).parsed_get(page_url_from_image_url, follow: { max_hops: 1 })
      end

      memoize def uuid
        if deviation_extended.present?
          deviation_extended["deviationUuid"]
        else # for sta.sh posts
          page&.at('meta[property="da:appurl"]')&.attr("content")&.delete_prefix("DeviantArt://deviation/")
        end
      end

      memoize def user
        page_json.dig("@@entities", "user")&.values&.first || {}
      end

      memoize def deviation
        page_json.dig("@@entities", "deviation")&.values&.first || {}
      end

      memoize def deviation_extended
        page_json.dig("@@entities", "deviationExtended")&.values&.first || {}
      end

      memoize def page_json
        return {} if page.nil?

        script = page&.css("body script").to_a.map(&:text).grep(/window.__INITIAL_STATE__/).first.to_s
        json = script[/window.__INITIAL_STATE__ = JSON.parse\("(.*)"\);/, 1]
        json.to_s.gsub('\\"', '"').gsub("\\\\", "\\").parse_json || {}
      end

      memoize def api_client
        api_client = DeviantArtApiClient.new(Danbooru.config.deviantart_client_id, Danbooru.config.deviantart_client_secret, http)
        api_client.access_token = Cache.get("da-access-token", 11.weeks) do
          api_client.access_token.to_hash
        end
        api_client
      end

      memoize def api_deviation
        return {} if uuid.nil?
        api_client.deviation(uuid)
      end

      memoize def api_metadata
        return {} if uuid.nil?
        api_client.metadata(uuid)[:metadata].first || {}
      end

      memoize def api_download
        return {} unless uuid.present?
        api_client.download(uuid)
      end

      def api_response
        {
          deviation: api_deviation,
          metadata: api_metadata,
          download: api_download,
          page_json: page_json,
        }
      end
    end
  end
end
