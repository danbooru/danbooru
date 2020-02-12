class Artist < ApplicationRecord
  extend Memoist
  class RevertError < StandardError; end

  attr_accessor :url_string_changed
  array_attribute :other_names
  api_attributes including: [:urls]

  before_validation :normalize_name
  before_validation :normalize_other_names
  after_save :create_version
  after_save :update_wiki
  after_save :clear_url_string_changed
  validate :validate_tag_category
  validates :name, tag_name: true, uniqueness: true
  belongs_to :creator, class_name: "User"
  has_many :members, :class_name => "Artist", :foreign_key => "group_name", :primary_key => "name"
  has_many :urls, :dependent => :destroy, :class_name => "ArtistUrl", :autosave => true
  has_many :versions, -> {order("artist_versions.id ASC")}, :class_name => "ArtistVersion"
  has_one :wiki_page, :foreign_key => "title", :primary_key => "name"
  has_one :tag_alias, :foreign_key => "antecedent_name", :primary_key => "name"
  belongs_to :tag, foreign_key: "name", primary_key: "name", default: -> { Tag.new(name: name, category: Tag.categories.artist) }
  attribute :notes, :string

  scope :active, -> { where(is_active: true) }
  scope :deleted, -> { where(is_active: false) }
  scope :banned, -> { where(is_banned: true) }
  scope :unbanned, -> { where(is_banned: false) }

  module UrlMethods
    extend ActiveSupport::Concern

    module ClassMethods
      # Subdomains are automatically included. e.g., "twitter.com" matches "www.twitter.com",
      # "mobile.twitter.com" and any other subdomain of "twitter.com".
      SITE_BLACKLIST = [
        "artstation.com/artist", # http://www.artstation.com/artist/serafleur/
        "www.artstation.com", # http://www.artstation.com/serafleur/
        %r!cdn[ab]?\.artstation\.com/p/assets/images/images!i, # https://cdna.artstation.com/p/assets/images/images/001/658/068/large/yang-waterkuma-b402.jpg?1450269769
        "ask.fm", # http://ask.fm/mikuroko_396
        "bcyimg.com",
        "bcyimg.com/drawer", # https://img9.bcyimg.com/drawer/32360/post/178vu/46229ec06e8111e79558c1b725ebc9e6.jpg
        "bcy.net",
        "bcy.net/illust/detail", # https://bcy.net/illust/detail/32360/1374683
        "bcy.net/u", # http://bcy.net/u/1390261
        "behance.net", # "https://www.behance.net/webang111
        "booru.org",
        "booru.org/drawfriends", # http://img.booru.org/drawfriends//images/36/de65da5f588b76bc1d9de8af976b540e2dff17e2.jpg
        "donmai.us",
        "donmai.us/users", # http://danbooru.donmai.us/users/507162/
        "derpibooru.org",
        "derpibooru.org/tags", # https://derpibooru.org/tags/artist-colon-checkerboardazn
        "deviantart.com",
        "deviantart.net",
        "dlsite.com",
        "doujinshi.org",
        "doujinshi.org/browse/circle", # http://www.doujinshi.org/browse/circle/65368/
        "doujinshi.org/browse/author", # http://www.doujinshi.org/browse/author/979/23/
        "doujinshi.mugimugi.org",
        "doujinshi.mugimugi.org/browse/author", # http://doujinshi.mugimugi.org/browse/author/3029/
        "doujinshi.mugimugi.org/browse/circle", # http://doujinshi.mugimugi.org/browse/circle/7210/
        "drawcrowd.net", # https://drawcrowd.com/agussw
        "drawr.net", # http://drawr.net/matsu310
        "dropbox.com",
        "dropbox.com/sh", # https://www.dropbox.com/sh/gz9okupqycr2vj2/GHt_oHDKsR
        "dropbox.com/u", # http://dl.dropbox.com/u/76682289/daitoHP-WP/pict/
        "e-hentai.org", # https://e-hentai.org/tag/artist:spirale
        "e621.net",
        "e621.net/post/index/1", # https://e621.net/post/index/1/spirale
        "enty.jp", # https://enty.jp/aizawachihiro888
        "enty.jp/users", # https://enty.jp/users/3766
        "facebook.com", # https://www.facebook.com/LuutenantsLoot
        "fantia.jp", # http://fantia.jp/no100
        "fantia.jp/fanclubs", # https://fantia.jp/fanclubs/1711
        "fav.me", # http://fav.me/d9y1njg
        /blog-imgs-\d+(?:-origin)?\.fc2\.com/i,
        "furaffinity.net",
        "furaffinity.net/user", # http://www.furaffinity.net/user/achthenuts
        "gelbooru.com", # http://gelbooru.com/index.php?page=account&s=profile&uname=junou
        "inkbunny.net", # https://inkbunny.net/achthenuts
        "plus.google.com", # https://plus.google.com/111509637967078773143/posts
        "hentai-foundry.com",
        "hentai-foundry.com/pictures/user", # http://www.hentai-foundry.com/pictures/user/aaaninja/
        "hentai-foundry.com/user", # http://www.hentai-foundry.com/user/aaaninja/profile
        %r!pictures\.hentai-foundry\.com(?:/\w)?!i, # http://pictures.hentai-foundry.com/a/aaaninja/
        "i.imgur.com", # http://i.imgur.com/Ic9q3.jpg
        "instagram.com", # http://www.instagram.com/serafleur.art/
        "iwara.tv",
        "iwara.tv/users", # http://ecchi.iwara.tv/users/marumega
        "kym-cdn.com",
        "livedoor.blogimg.jp",
        "monappy.jp",
        "monappy.jp/u", # https://monappy.jp/u/abara_bone
        "mstdn.jp", # https://mstdn.jp/@oneb
        "nicoseiga.jp",
        "nicoseiga.jp/priv", # http://lohas.nicoseiga.jp/priv/2017365fb6cfbdf47ad26c7b6039feb218c5e2d4/1498430264/6820259
        "nicovideo.jp",
        "nicovideo.jp/user", # http://www.nicovideo.jp/user/317609
        "nicovideo.jp/user/illust", # http://seiga.nicovideo.jp/user/illust/29075429
        "nijie.info", # http://nijie.info/members.php?id=15235
        %r!nijie\.info/nijie_picture!i, # http://pic03.nijie.info/nijie_picture/32243_20150609224803_0.png
        "patreon.com", # http://patreon.com/serafleur
        "pawoo.net", # https://pawoo.net/@148nasuka
        "pawoo.net/web/accounts", # https://pawoo.net/web/accounts/228341
        "picarto.tv", # https://picarto.tv/CheckerBoardAZN
        "picarto.tv/live", # https://www.picarto.tv/live/channel.php?watch=aaaninja
        "pictaram.com", # http://www.pictaram.com/user/5ish/3048385011/1350040096769940245_3048385011
        "pinterest.com", # http://www.pinterest.com/alexandernanitc/
        "pixiv.cc", # http://pixiv.cc/0123456789/
        "pixiv.net", # https://www.pixiv.net/member.php?id=10442390
        "pixiv.net/stacc", # https://www.pixiv.net/stacc/aaaninja2013
        "pixiv.net/fanbox/creator", # https://www.pixiv.net/fanbox/creator/310630
        "pixiv.net/users", # https://www.pixiv.net/users/555603
        "pixiv.net/en/users", # https://www.pixiv.net/en/users/555603
        "i.pximg.net",
        "plurk.com", # http://www.plurk.com/a1amorea1a1
        "privatter.net",
        "privatter.net/u", # http://privatter.net/u/saaaatonaaaa
        "rule34.paheal.net",
        "rule34.paheal.net/post/list", # http://rule34.paheal.net/post/list/Reach025/
        "sankakucomplex.com", # https://chan.sankakucomplex.com/?tags=user%3ASubridet
        "society6.com", # http://society6.com/serafleur/
        "tinami.com",
        "tinami.com/creator/profile", # http://www.tinami.com/creator/profile/29024
        "data.tumblr.com",
        /\d+\.media\.tumblr\.com/i,
        "twipple.jp",
        "twipple.jp/user", # http://p.twipple.jp/user/Type10TK
        "twitch.tv", # https://www.twitch.tv/5ish
        "twitpic.com",
        "twitpic.com/photos", # http://twitpic.com/photos/Type10TK
        "twitter.com", # https://twitter.com/akkij0358
        "twitter.com/i/web/status", # https://twitter.com/i/web/status/943446161586733056
        "twimg.com/media", # https://pbs.twimg.com/media/DUUUdD5VMAEuURz.jpg:orig
        "ustream.tv",
        "ustream.tv/channel", # http://www.ustream.tv/channel/633b
        "ustream.tv/user", # http://www.ustream.tv/user/kazaputi
        "vk.com", # https://vk.com/id425850679
        "weibo.com", # http://www.weibo.com/5536681649
        "wp.com",
        "yande.re",
        "youtube.com",
        "youtube.com/c", # https://www.youtube.com/c/serafleurArt
        "youtube.com/channel", # https://www.youtube.com/channel/UCfrCa2Y6VulwHD3eNd3HBRA
        "youtube.com/user", # https://www.youtube.com/user/148nasuka
        "youtu.be" # http://youtu.be/gibeLKKRT-0
      ]

      SITE_BLACKLIST_REGEXP = Regexp.union(SITE_BLACKLIST.map do |domain|
        domain = Regexp.escape(domain) if domain.is_a?(String)
        %r!\Ahttps?://(?:[a-zA-Z0-9_-]+\.)*#{domain}/\z!i
      end)

      def find_artists(url)
        url = ArtistUrl.normalize(url)
        artists = []

        # return [] unless Sources::Strategies.find(url).normalized_for_artist_finder?

        while artists.empty? && url.size > 10
          u = url.sub(/\/+$/, "") + "/"
          u = u.to_escaped_for_sql_like.gsub(/\*/, '%') + '%'
          artists += Artist.joins(:urls).where(["artists.is_active = TRUE AND artist_urls.normalized_url LIKE ? ESCAPE E'\\\\'", u]).limit(10).order("artists.name").all
          url = File.dirname(url) + "/"

          break if url =~ SITE_BLACKLIST_REGEXP
        end

        where(id: artists.uniq(&:name).take(20))
      end
    end

    def sorted_urls
      urls.sort {|a, b| a.priority <=> b.priority}
    end

    def url_array
      urls.map(&:to_s).sort
    end

    def url_string
      url_array.join("\n")
    end

    def url_string=(string)
      url_string_was = url_string

      self.urls = string.to_s.scan(/[^[:space:]]+/).map do |url|
        is_active, url = ArtistUrl.parse_prefix(url)
        self.urls.find_or_initialize_by(url: url, is_active: is_active)
      end.uniq(&:url)

      self.url_string_changed = (url_string_was != url_string)
    end

    def clear_url_string_changed
      self.url_string_changed = false
    end
  end

  module NameMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def normalize_name(name)
        name.to_s.mb_chars.downcase.strip.gsub(/ /, '_').to_s
      end
    end

    def normalize_name
      self.name = Artist.normalize_name(name)
    end

    def pretty_name
      name.tr("_", " ")
    end

    def normalize_other_names
      self.other_names = other_names.map { |x| Artist.normalize_name(x) }.uniq
      self.other_names -= [name]
    end
  end

  module VersionMethods
    def create_version(force = false)
      if saved_change_to_name? || url_string_changed || saved_change_to_is_active? || saved_change_to_is_banned? || saved_change_to_other_names? || saved_change_to_group_name? || saved_change_to_notes? || force
        if merge_version?
          merge_version
        else
          create_new_version
        end
      end
    end

    def create_new_version
      ArtistVersion.create(
        :artist_id => id,
        :name => name,
        :updater_id => CurrentUser.id,
        :updater_ip_addr => CurrentUser.ip_addr,
        :urls => url_array,
        :is_active => is_active,
        :is_banned => is_banned,
        :other_names => other_names,
        :group_name => group_name
      )
    end

    def merge_version
      prev = versions.last
      prev.update(name: name, urls: url_array, is_active: is_active, is_banned: is_banned, other_names: other_names, group_name: group_name)
    end

    def merge_version?
      prev = versions.last
      prev && prev.updater_id == CurrentUser.user.id && prev.updated_at > 1.hour.ago
    end

    def revert_to!(version)
      if id != version.artist_id
        raise RevertError.new("You cannot revert to a previous version of another artist.")
      end

      self.name = version.name
      self.url_string = version.urls.join("\n")
      self.is_active = version.is_active
      self.other_names = version.other_names
      self.group_name = version.group_name
      save
    end
  end

  module FactoryMethods
    # Make a new artist, fetching the defaults either from the given source, or
    # from the source of the artist's last upload.
    def new_with_defaults(params)
      source = params.delete(:source)

      if source.blank? && params[:name].present?
        CurrentUser.without_safe_mode do
          post = Post.tag_match("source:http* #{params[:name]}").first
          source = post.try(:source)
        end
      end

      if source.present?
        artist = Sources::Strategies.find(source).new_artist
        artist.attributes = params
      else
        artist = Artist.new(params)
      end

      artist.normalize_name
      artist.normalize_other_names
      artist
    end
  end

  module NoteMethods
    extend ActiveSupport::Concern

    def notes
      @notes || wiki_page.try(:body)
    end

    def notes=(text)
      if notes != text
        notes_will_change!
        @notes = text
      end
    end

    def reload(options = nil)
      flush_cache

      if instance_variable_defined?(:@notes)
        remove_instance_variable(:@notes)
      end

      super
    end

    def notes_changed?
      attribute_changed?("notes")
    end

    def notes_will_change!
      attribute_will_change!("notes")
    end

    def update_wiki
      if persisted? && saved_change_to_name? && attribute_before_last_save("name").present? && WikiPage.titled(attribute_before_last_save("name")).exists?
        # we're renaming the artist, so rename the corresponding wiki page
        old_page = WikiPage.titled(name_before_last_save).first

        if wiki_page.present?
          # a wiki page with the new name already exists, so update the content
          wiki_page.update(body: "#{wiki_page.body}\n\n#{@notes}")
        else
          # a wiki page doesn't already exist for the new name, so rename the old one
          old_page.update(title: name, body: @notes)
        end
      elsif wiki_page.nil?
        # if there are any notes, we need to create a new wiki page
        if @notes.present?
          create_wiki_page(body: @notes, title: name)
        end
      elsif (!@notes.nil? && (wiki_page.body != @notes)) || wiki_page.title != name
        # if anything changed, we need to update the wiki page
        wiki_page.body = @notes unless @notes.nil?
        wiki_page.title = name
        wiki_page.save
      end
    end
  end

  module TagMethods
    def category_name
      Tag.category_for(name)
    end

    def validate_tag_category
      return unless is_active? && name_changed?

      if tag.category_name == "General"
        tag.update(category: Tag.categories.artist)
      elsif tag.category_name != "Artist"
        errors[:base] << "'#{name}' is a #{tag.category_name.downcase} tag; artist entries can only be created for artist tags"
      end
    end
  end

  module BanMethods
    def unban!
      Post.transaction do
        CurrentUser.without_safe_mode do
          ti = TagImplication.find_by(antecedent_name: name, consequent_name: "banned_artist")
          ti&.destroy

          Post.tag_match(name).find_each do |post|
            post.unban!
            fixed_tags = post.tag_string.sub(/(?:\A| )banned_artist(?:\Z| )/, " ").strip
            post.update(tag_string: fixed_tags)
          end

          update_column(:is_banned, false)
          ModAction.log("unbanned artist ##{id}", :artist_unban)
        end
      end
    end

    def ban!(banner: CurrentUser.user)
      Post.transaction do
        CurrentUser.without_safe_mode do
          Post.tag_match(name).each(&:ban!)

          # potential race condition but unlikely
          unless TagImplication.where(:antecedent_name => name, :consequent_name => "banned_artist").exists?
            tag_implication = TagImplication.create!(antecedent_name: name, consequent_name: "banned_artist", skip_secondary_validations: true, creator: banner)
            tag_implication.approve!(approver: banner)
          end

          update_column(:is_banned, true)
          ModAction.log("banned artist ##{id}", :artist_ban)
        end
      end
    end
  end

  module SearchMethods
    def any_other_name_matches(regex)
      where(id: Artist.from("unnest(other_names) AS other_name").where_regex("other_name", regex))
    end

    def any_other_name_like(name)
      where(id: Artist.from("unnest(other_names) AS other_name").where_like("other_name", name))
    end

    def any_name_matches(query)
      if query =~ %r!\A/(.*)/\z!
        where_regex(:name, $1).or(any_other_name_matches($1)).or(where_regex(:group_name, $1))
      else
        normalized_name = normalize_name(query)
        normalized_name = "*#{normalized_name}*" unless normalized_name.include?("*")
        where_like(:name, normalized_name).or(any_other_name_like(normalized_name)).or(where_like(:group_name, normalized_name))
      end
    end

    def url_matches(query)
      if query =~ %r!\A/(.*)/\z!
        where(id: ArtistUrl.where_regex(:url, $1).select(:artist_id))
      elsif query.include?("*")
        where(id: ArtistUrl.where_like(:url, query).select(:artist_id))
      elsif query =~ %r!\Ahttps?://!i
        find_artists(query)
      else
        where(id: ArtistUrl.where_like(:url, "*#{query}*").select(:artist_id))
      end
    end

    def any_name_or_url_matches(query)
      if query =~ %r!\Ahttps?://!i
        url_matches(query)
      else
        any_name_matches(query)
      end
    end

    def search(params)
      q = super

      q = q.search_attributes(params, :is_active, :is_banned, :creator, :name, :group_name, :other_names)

      if params[:any_other_name_like]
        q = q.any_other_name_like(params[:any_other_name_like])
      end

      if params[:any_name_matches].present?
        q = q.any_name_matches(params[:any_name_matches])
      end

      if params[:any_name_or_url_matches].present?
        q = q.any_name_or_url_matches(params[:any_name_or_url_matches])
      end

      if params[:url_matches].present?
        q = q.url_matches(params[:url_matches])
      end

      if params[:has_tag].to_s.truthy?
        q = q.joins(:tag).where("tags.post_count > 0")
      elsif params[:has_tag].to_s.falsy?
        q = q.includes(:tag).where("tags.name IS NULL OR tags.post_count <= 0").references(:tags)
      end

      case params[:order]
      when "name"
        q = q.order("artists.name")
      when "updated_at"
        q = q.order("artists.updated_at desc")
      when "post_count"
        q = q.includes(:tag).order("tags.post_count desc nulls last").order("artists.name").references(:tags)
      else
        q = q.apply_default_order(params)
      end

      q
    end
  end

  include UrlMethods
  include NameMethods
  include VersionMethods
  extend FactoryMethods
  include NoteMethods
  include TagMethods
  include BanMethods
  extend SearchMethods

  def status
    if is_banned? && is_active?
      "Banned"
    elsif is_banned?
      "Banned Deleted"
    elsif is_active?
      "Active"
    else
      "Deleted"
    end
  end

  def self.available_includes
    [:creator, :members, :urls, :wiki_page, :tag_alias, :tag]
  end
end
