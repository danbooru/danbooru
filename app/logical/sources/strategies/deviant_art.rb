# Asset URLs:
#
# * http://orig12.deviantart.net/9b69/f/2017/023/7/c/illustration___tokyo_encount_oei__by_melisaongmiqin-dawi58s.png
# * http://pre15.deviantart.net/81de/th/pre/f/2015/063/5/f/inha_by_inhaestudios-d8kfzm5.jpg
# * http://th00.deviantart.net/fs71/PRE/f/2014/065/3/b/goruto_by_xyelkiltrox-d797tit.png
#
# * http://th04.deviantart.net/fs70/300W/f/2009/364/4/d/Alphes_Mimic___Rika_by_Juriesute.png
# * http://fc02.deviantart.net/fs48/f/2009/186/2/c/Animation_by_epe_tohri.swf
# * http://fc08.deviantart.net/files/f/2007/120/c/9/Cool_Like_Me_by_47ness.jpg
#
# * http://fc08.deviantart.net/images3/i/2004/088/8/f/Blackrose_for_MuzicFreq.jpg
# * http://img04.deviantart.net/720b/i/2003/37/9/6/princess_peach.jpg
#
# * http://prnt00.deviantart.net/9b74/b/2016/101/4/468a9d89f52a835d4f6f1c8caca0dfb2-pnjfbh.jpg
# * http://fc00.deviantart.net/fs71/f/2013/234/d/8/d84e05f26f0695b1153e9dab3a962f16-d6j8jl9.jpg
# * http://th04.deviantart.net/fs71/PRE/f/2013/337/3/5/35081351f62b432f84eaeddeb4693caf-d6wlrqs.jpg
#
# * http://fc09.deviantart.net/fs22/o/2009/197/3/7/37ac79eaeef9fb32e6ae998e9a77d8dd.jpg
# * http://pre06.deviantart.net/8497/th/pre/f/2009/173/c/c/cc9686111dcffffffb5fcfaf0cf069fb.jpg
#
# * https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg/v1/fill/w_786,h_1017,q_70,strp/silverhawks_quicksilver_by_edsfox_d23jbr4-pre.jpg
# * https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/fe7ab27f-7530-4252-99ef-2baaf81b36fd/dddf6pe-1a4a091c-768c-4395-9465-5d33899be1eb.png/v1/fill/w_800,h_1130,q_80,strp/stay_hydrated_and_in_the_shade_by_raikoart_dddf6pe-fullview.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7ImhlaWdodCI6Ijw9MTEzMCIsInBhdGgiOiJcL2ZcL2ZlN2FiMjdmLTc1MzAtNDI1Mi05OWVmLTJiYWFmODFiMzZmZFwvZGRkZjZwZS0xYTRhMDkxYy03NjhjLTQzOTUtOTQ2NS01ZDMzODk5YmUxZWIucG5nIiwid2lkdGgiOiI8PTgwMCJ9XV0sImF1ZCI6WyJ1cm46c2VydmljZTppbWFnZS5vcGVyYXRpb25zIl19.J0W4k-iV6Mg8Kt_5Lr_L_JbBq4lyr7aCausWWJ_Fsbw
#
# Page URLs:
#
# * https://www.deviantart.com/noizave/art/test-post-please-ignore-685436408
# * https://noizave.deviantart.com/art/test-post-please-ignore-685436408
# * https://www.deviantart.com/deviation/685436408
# * https://fav.me/dbc3a48
#
# Profile URLs:
#
# * https://noizave.deviantart.com
# * https://www.deviantart.com/noizave
# * https://deviantart.com/noizave

module Sources
  module Strategies
    class DeviantArt < Base
      ASSET_SUBDOMAINS = %r{(?:fc|th|pre|img|orig|origin-orig)\d*}i
      RESERVED_SUBDOMAINS = %r{\Ahttps?://(?:#{ASSET_SUBDOMAINS}|www)\.}i

      TITLE = %r{(?<title>[a-z0-9_-]+?)}i
      ARTIST = %r{(?<artist>[a-z0-9_-]+?)}i
      DEVIATION_ID = %r{(?<deviation_id>[0-9]+)}i

      DA_FILENAME  = %r{#{TITLE}(?:_by_#{ARTIST}(?:-d(?<base36_deviation_id>[a-z0-9]+))?)?\.}i
      WIX_FILENAME = %r{#{TITLE}_by_#{ARTIST}_d(?<base36_deviation_id>[a-z0-9]+)-[a-z0-9]+\.}i

      DA_ASSET = %r{\Ahttps?://#{ASSET_SUBDOMAINS}\.deviantart\.net/.+/#{DA_FILENAME}}i
      WIX_ASSET = %r{\Ahttps?://images-wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/.+/#{WIX_FILENAME}}i
      ASSET = Regexp.union(DA_ASSET, WIX_ASSET)

      PATH_ART = %r{\Ahttps?://www\.deviantart\.com/#{ARTIST}/art/#{TITLE}-#{DEVIATION_ID}\z}i
      SUBDOMAIN_ART = %r{\Ahttps?://#{ARTIST}\.deviantart\.com/art/#{TITLE}-#{DEVIATION_ID}\z}i

      PATH_PROFILE = %r{\Ahttps?://(www\.)?deviantart\.com/#{ARTIST}/?\z}i
      SUBDOMAIN_PROFILE = %r{\Ahttps?://#{ARTIST}\.deviantart\.com/?\z}i

      def domains
        ["deviantart.net", "deviantart.com"]
      end

      def site_name
        "Deviant Art"
      end

      def match?
        return false if parsed_url.nil?
        parsed_url.domain.in?(domains) || parsed_url.host == "images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com"
      end

      def canonical_url
        if self.class.deviation_id_from_url(image_url).present? || page_url.blank?
          image_url
        else
          page_url
        end
      end

      def image_urls
        [image_url]
      end

      def image_url
        # work is private, deleted, or the url didn't contain a deviation id; use image url as given by user.
        if api_deviation.blank?
          url
        elsif api_deviation[:isDownloadable]
          api_client.download_url
        else
          media = api_deviation[:media]
          token = media[:token].first
          fullview = media[:types].find { |data| data[:t] == "fullview" && data[:c].present? }

          if fullview.present?
            op = fullview[:c].gsub('<prettyName>', media[:prettyName])
            src = "#{media[:baseUri]}/#{op}?token=#{token}"
          else
            src = "#{media[:baseUri]}?token=#{token}"
          end

          if deviation_id && deviation_id.to_i <= 790677560 && src =~ /\Ahttps:\/\/images-wixmp-/i
            src = src.gsub(%r!(/f/[a-f0-9-]+/[a-f0-9-]+)!, '/intermediary\1')
            src = src.gsub(%r!/v1/(fit|fill)/.*\z!i, "")
          end

          src = src.gsub(%r!\Ahttps?://orig\d+\.deviantart\.net!i, "http://origin-orig.deviantart.net")
          src = src.gsub(%r!q_\d+,strp!, "q_100")
          src
        end
      end

      def page_url
        if api_deviation[:url].present?
          api_deviation[:url]
        elsif deviation_id.present?
          page_url_from_image_url
        else
          nil
        end
      end

      def page_url_from_image_url
        artist, title, id = artist_name_from_url, title_from_url, deviation_id

        if artist.present? && title.present? && id.present?
          "https://www.deviantart.com/#{artist}/art/#{title}-#{id}"
        elsif id.present?
          "https://deviantart.com/deviation/#{id}"
        else
          nil
        end
      end

      def profile_url
        return nil if artist_name.blank?
        "https://www.deviantart.com/#{artist_name.downcase}"
      end

      # Prefer the name from the url because the api metadata won't be present when
      # the input url doesn't contain a deviation id, or the deviation is private or deleted.
      def artist_name
        if artist_name_from_url.present?
          artist_name_from_url
        elsif api_deviation.dig(:author, :username).present?
          api_metadata.dig(:author, :username)
        else
          nil
        end
      end

      def artist_commentary_title
        api_deviation[:title]
      end

      def artist_commentary_desc
        return nil unless api_deviation.dig(:extended, :description).present?
        api_deviation.dig(:extended, :description)
      end

      def normalized_for_artist_finder?
        url == normalize_for_artist_finder
      end

      def normalizable_for_artist_finder?
        normalize_for_artist_finder.present?
      end

      def normalize_for_artist_finder
        profile_url
      end

      def tags
        return [] unless api_deviation.dig(:extended, :tags).present?

        api_deviation.dig(:extended, :tags).map do |tag|
          [tag[:name], tag[:url]]
        end
      end

      def dtext_artist_commentary_desc
        DText.from_html(artist_commentary_desc) do |element|
          # Convert embedded thumbnails of journal posts to 'deviantart #123'
          # links. Strip embedded thumbnails of image posts. Example:
          # https://sa-dui.deviantart.com/art/Commission-Meinos-Kaen-695905927.
          if element.name == "a" && element["data-sigil"] == "thumb"
            element.name = "span"

            # <a href="https://sa-dui.deviantart.com/journal/About-Commissions-223178193" data-sigil="thumb" class="thumb lit" ...>
            if element["class"].split.include?("lit")
              deviation_id = element["href"][%r!-(\d+)\z!, 1].to_i
              element.content = "deviantart ##{deviation_id}"
            else
              element.content = ""
            end
          end

          if element.name == "a" && element["href"].present?
            element["href"] = element["href"].gsub(%r!\Ahttps?://www\.deviantart\.com/users/outgoing\?!i, "")

            # href may be missing the `http://` bit (ex: `inprnt.com`, `//inprnt.com`). Add it if missing.
            uri = Addressable::URI.heuristic_parse(element["href"]) rescue nil
            if uri.present? && uri.path.present?
              uri.scheme ||= "http"
              element["href"] = uri.to_s
            end
          end
        end.gsub(/\A[[:space:]]+|[[:space:]]+\z/, "")
      end

      def self.deviation_id_from_url(url)
        if url =~ ASSET
          $~[:base36_deviation_id].try(:to_i, 36)
        elsif url =~ PATH_ART || (url !~ RESERVED_SUBDOMAINS && url =~ SUBDOMAIN_ART)
          $~[:deviation_id].to_i
        else
          nil
        end
      end

      def self.artist_name_from_url(url)
        if url =~ ASSET || url =~ PATH_ART || url =~ PATH_PROFILE
          $~[:artist].try(:dasherize)
        elsif url !~ RESERVED_SUBDOMAINS && (url =~ SUBDOMAIN_ART || url =~ SUBDOMAIN_PROFILE)
          $~[:artist]
        else
          nil
        end
      end

      def self.title_from_url(url)
        if url =~ ASSET || url =~ PATH_ART || url =~ PATH_PROFILE
          $~[:title].to_s.titleize.strip.squeeze(" ").tr(" ", "-").presence
        elsif url !~ RESERVED_SUBDOMAINS && (url =~ SUBDOMAIN_ART || url =~ SUBDOMAIN_PROFILE)
          $~[:title].to_s.titleize.strip.squeeze(" ").tr(" ", "-").presence
        else
          nil
        end
      end

      def deviation_id
        self.class.deviation_id_from_url(url) || self.class.deviation_id_from_url(referer_url)
      end

      def artist_name_from_url
        self.class.artist_name_from_url(url) || self.class.artist_name_from_url(referer_url)
      end

      def title_from_url
        self.class.title_from_url(url) || self.class.title_from_url(referer_url)
      end

      def api_client
        @api_client ||= DeviantArtApiClient.new(deviation_id)
      end

      def api_deviation
        api_client.extended_fetch_json[:deviation] || {}
      end

      def api_response
        {
          code: api_client.extended_fetch.code,
          headers: api_client.extended_fetch.headers.to_h,
          body: api_client.extended_fetch_json
        }
      end
    end
  end
end
