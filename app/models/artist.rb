class Artist < ActiveRecord::Base
  extend Memoist
  class RevertError < Exception ; end

  before_create :initialize_creator
  before_validation :normalize_name
  after_save :create_version
  after_save :save_url_string
  after_save :categorize_tag
  after_save :update_wiki
  validates_uniqueness_of :name
  validate :validate_name
  validate :validate_wiki, :on => :create
  belongs_to :creator, :class_name => "User"
  has_many :members, :class_name => "Artist", :foreign_key => "group_name", :primary_key => "name"
  has_many :urls, :dependent => :destroy, :class_name => "ArtistUrl"
  has_many :versions, lambda {order("artist_versions.id ASC")}, :class_name => "ArtistVersion"
  has_one :wiki_page, :foreign_key => "title", :primary_key => "name"
  has_one :tag_alias, :foreign_key => "antecedent_name", :primary_key => "name"
  has_one :tag, :foreign_key => "name", :primary_key => "name"
  attr_accessible :body, :notes, :name, :url_string, :other_names, :other_names_comma, :group_name, :notes, :as => [:member, :gold, :builder, :platinum, :moderator, :default, :admin]
  attr_accessible :is_active, :as => [:builder, :moderator, :default, :admin]
  attr_accessible :is_banned, :as => :admin

  scope :active, lambda { where(is_active: true) }
  scope :deleted, lambda { where(is_active: false) }
  scope :banned, lambda { where(is_banned: true) }
  scope :unbanned, lambda { where(is_banned: false) }

  module UrlMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def find_all_by_url(url)
        url = ArtistUrl.normalize(url)
        artists = []

        # return [] unless Sources::Site.new(url).normalized_for_artist_finder?

        while artists.empty? && url.size > 10
          u = url.sub(/\/+$/, "") + "/"
          u = u.to_escaped_for_sql_like.gsub(/\*/, '%') + '%'
          artists += Artist.joins(:urls).where(["artists.is_active = TRUE AND artist_urls.normalized_url LIKE ? ESCAPE E'\\\\'", u]).limit(10).order("artists.name").all
          url = File.dirname(url) + "/"
          break if url =~ /pixiv\.net\/(?:img\/)?$/i
          break if url =~ /lohas\.nicoseiga\.jp\/priv\/$/i
          break if url =~ /(?:data|media)\.tumblr\.com\/[a-z0-9]+\/$/i
          break if url =~ /deviantart\.net\//i
          break if url =~ %r!\Ahttps?://(?:mobile\.)?twitter\.com/\Z!i
        end

        artists.inject({}) {|h, x| h[x.name] = x; h}.values.slice(0, 20)
      end
    end

    included do
      memoize :domains
    end

    def url_array
      urls.map(&:url)
    end

    def save_url_string
      if @url_string
        prev = url_array
        curr = @url_string.scan(/\S+/).uniq

        duplicates = prev.select{|url| prev.count(url) > 1}.uniq
        duplicates.each do |url|
          count = prev.count(url)
          urls.where(:url => url).limit(count-1).destroy_all
        end

        (prev - curr).each do |url|
          urls.where(:url => url).destroy_all
        end

        (curr - prev).each do |url|
          urls.create(:url => url)
        end
      end
    end

    def url_string=(string)
      @url_string = string
    end

    def url_string
      @url_string || url_array.join("\n")
    end

    def url_string_changed?
      url_string.scan(/\S+/) != url_array
    end

    def map_domain(x)
      case x
      when "pximg.net"
        "pixiv.net"

      when "deviantart.net"
        "deviantart.com"

      else
        x
      end
    end

    def domains
      Cache.get("artist-domains-#{id}", 1.day) do
        Post.raw_tag_match(name).pluck(:source).map do |x| 
          begin
            map_domain(Addressable::URI.parse(x).domain)
          rescue Addressable::URI::InvalidURIError
            nil
          end
        end.compact.inject(Hash.new(0)) {|h, x| h[x] += 1; h}.sort {|a, b| b[1] <=> a[1]}
      end
    end
  end

  module NameMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def normalize_name(name)
        name.to_s.mb_chars.downcase.strip.gsub(/ /, '_').to_s
      end
    end

    def validate_name
      if name =~ /^[-~]/
        errors[:name] << "cannot begin with - or ~"
        false
      elsif name =~ /\*/
        errors[:name] << "cannot contain *"
        false
      else
        true
      end
    end

    def normalize_name
      self.name = Artist.normalize_name(name)
    end

    def pretty_name
      name.tr("_", " ")
    end

    def other_names_array
      other_names.try(:split, /\s/)
    end

    def other_names_comma
      other_names_array.try(:join, ", ")
    end

    def other_names_comma=(string)
      self.other_names = string.split(/,/).map {|x| Artist.normalize_name(x)}.join(" ")
    end
  end

  module GroupMethods
    def member_names
      members.map(&:name).join(", ")
    end
  end

  module VersionMethods
    def create_version(force=false)
      if name_changed? || url_string_changed? || is_active_changed? || is_banned_changed? || other_names_changed? || group_name_changed? || notes_changed? || force
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
        :updater_id => CurrentUser.user.id,
        :updater_ip_addr => CurrentUser.ip_addr,
        :url_string => url_string,
        :is_active => is_active,
        :is_banned => is_banned,
        :other_names => other_names,
        :group_name => group_name
      )
    end

    def merge_version
      prev = versions.last
      prev.update_attributes(
        :name => name,
        :url_string => url_string,
        :is_active => is_active,
        :is_banned => is_banned,
        :other_names => other_names,
        :group_name => group_name
      )
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
      self.url_string = version.url_string
      self.is_active = version.is_active
      self.other_names = version.other_names
      self.group_name = version.group_name
      save
    end
  end

  module FactoryMethods
    def new_with_defaults(params)
      Artist.new.tap do |artist|
        if params[:name]
          artist.name = params[:name]
          post = CurrentUser.without_safe_mode do
            Post.tag_match("source:http #{artist.name}").where("true /* Artist.new_with_defaults */").first
          end
          unless post.nil? || post.source.blank?
            artist.url_string = post.source
          end
        end

        if params[:other_names]
          artist.other_names = params[:other_names]
        end

        if params[:urls]
          artist.url_string = params[:urls]
        end
      end
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
      if persisted? && name_changed? && name_was.present? && WikiPage.titled(name_was).exists?
        # we're renaming the artist, so rename the corresponding wiki page
        old_page = WikiPage.titled(name_was).first

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
      elsif wiki_page.body != @notes || wiki_page.title != name
        # if anything changed, we need to update the wiki page
        wiki_page.body = @notes unless @notes.nil?
        wiki_page.title = name
        wiki_page.save
      end
    end

    def validate_wiki
      if WikiPage.titled(name).exists?
        errors.add(:name, "conflicts with a wiki page")
        return false
      end
    end
  end

  module TagMethods
    def has_tag_alias?
      TagAlias.active.exists?(["antecedent_name = ?", name])
    end

    def tag_alias_name
      TagAlias.active.find_by_antecedent_name(name).consequent_name
    end

    def category_name
      Tag.category_for(name)
    end

    def categorize_tag
      if new_record? || name_changed?
        Tag.find_or_create_by_name("artist:#{name}")
      end
    end
  end

  module BanMethods
    def unban!
      Post.transaction do
        CurrentUser.without_safe_mode do
          ti = TagImplication.where(:antecedent_name => name, :consequent_name => "banned_artist").first
          ti.destroy if ti

          begin
            Post.tag_match(name).where("true /* Artist.unban */").each do |post|
              post.unban!
              fixed_tags = post.tag_string.sub(/(?:\A| )banned_artist(?:\Z| )/, " ").strip
              post.update_attributes(:tag_string => fixed_tags)
            end
          rescue Post::SearchError
            # swallow
          end

          update_column(:is_banned, false)
        end
      end
    end

    def ban!
      Post.transaction do
        CurrentUser.without_safe_mode do
          begin
            Post.tag_match(name).where("true /* Artist.ban */").each do |post|
              post.ban!
            end
          rescue Post::SearchError
            # swallow
          end

          # potential race condition but unlikely
          unless TagImplication.where(:antecedent_name => name, :consequent_name => "banned_artist").exists?
            tag_implication = TagImplication.create!(:antecedent_name => name, :consequent_name => "banned_artist", :skip_secondary_validations => true)
            tag_implication.approve!(approver: CurrentUser.user)
          end

          update_column(:is_banned, true)
        end
      end
    end
  end

  module SearchMethods
    def url_matches(string)
      matches = find_all_by_url(string).map(&:id)

      if matches.any?
        where("id in (?)", matches)
      elsif matches = search_for_profile(string)
        where("id in (?)", matches)
      else
        where("false")
      end
    end

    def search_for_profile(url)
      source = Sources::Site.new(url)
      if source.strategy
        source.get
        find_all_by_url(source.profile_url)
      else
        nil
      end
    rescue
      nil
    end

    def other_names_match(string)
      if string =~ /\*/ && CurrentUser.is_builder?
        where("artists.other_names ILIKE ? ESCAPE E'\\\\'", string.to_escaped_for_sql_like)
      else
        where("artists.other_names_index @@ to_tsquery('danbooru', E?)", Artist.normalize_name(string).to_escaped_for_tsquery)
      end
    end

    def group_name_matches(name)
      stripped_name = normalize_name(name).to_escaped_for_sql_like
      where("artists.group_name LIKE ? ESCAPE E'\\\\'", stripped_name)
    end

    def name_matches(name)
      stripped_name = normalize_name(name).to_escaped_for_sql_like
      where("artists.name LIKE ? ESCAPE E'\\\\'", stripped_name)
    end

    def named(name)
      where(name: normalize_name(name))
    end

    def any_name_matches(name)
      stripped_name = normalize_name(name).to_escaped_for_sql_like
      if name =~ /\*/ && CurrentUser.is_builder?
        where("(artists.name LIKE ? ESCAPE E'\\\\' OR artists.other_names LIKE ? ESCAPE E'\\\\')", stripped_name, stripped_name)
      else
        name_for_tsquery = normalize_name(name).to_escaped_for_tsquery
        where("(artists.name LIKE ? ESCAPE E'\\\\' OR artists.other_names_index @@ to_tsquery('danbooru', E?))", stripped_name, name_for_tsquery)
      end
    end

    def search(params)
      q = where("true")
      params = {} if params.blank?

      case params[:name]
      when /^http/
        q = q.url_matches(params[:name])

      when /name:(.+)/
        q = q.name_matches($1)

      when /other:(.+)/
        q = q.other_names_match($1)

      when /group:(.+)/
        q = q.group_name_matches($1)

      when /status:banned/
        q = q.banned

      when /status:active/
        q = q.unbanned.active

      when /./
        q = q.any_name_matches(params[:name])
      end

      if params[:name_matches].present?
        q = q.name_matches(params[:name_matches])
      end

      if params[:other_names_match].present?
        q = q.other_names_match(params[:other_names_match])
      end

      if params[:group_name_matches].present?
        q = q.group_name_matches(params[:group_name_matches])
      end

      if params[:any_name_matches].present?
        q = q.any_name_matches(params[:any_name_matches])
      end

      if params[:url_matches].present?
        q = q.url_matches(params[:url_matches])
      end

      params[:order] ||= params.delete(:sort)
      case params[:order]
      when "name"
        q = q.order("artists.name")
      when "updated_at"
        q = q.order("artists.updated_at desc")
      when "post_count"
        q = q.includes(:tag).order("tags.post_count desc nulls last").references(:tags)
      else
        q = q.order("artists.id desc")
      end

      if params[:is_active] == "true"
        q = q.active
      elsif params[:is_active] == "false"
        q = q.deleted
      end

      if params[:is_banned] == "true"
        q = q.banned
      elsif params[:is_banned] == "false"
        q = q.unbanned
      end

      if params[:id].present?
        q = q.where("id in (?)", params[:id].split(",").map(&:to_i))
      end

      if params[:creator_name].present?
        q = q.where("creator_id = (select _.id from users _ where lower(_.name) = ?)", params[:creator_name].tr(" ", "_").mb_chars.downcase)
      end

      if params[:creator_id].present?
        q = q.where("creator_id = ?", params[:creator_id].to_i)
      end

      # XXX deprecated, remove at some point.
      if params[:empty_only] == "true"
        params[:has_tag] = "false"
      end

      if params[:has_tag] == "true"
        q = q.joins(:tag).where("tags.post_count > 0")
      elsif params[:has_tag] == "false"
        q = q.includes(:tag).where("tags.name IS NULL OR tags.post_count <= 0").references(:tags)
      end

      q
    end
  end

  module ApiMethods
    def hidden_attributes
      super + [:other_names_index]
    end

    def method_attributes
      super + [:domains]
    end

    def legacy_api_hash
      return {
        :id => id,
        :name => name,
        :other_names => other_names,
        :group_name => group_name,
        :urls => artist_urls.map {|x| x.url},
        :is_active => is_active?,
        :updater_id => 0
      }
    end
  end

  include UrlMethods
  include NameMethods
  include GroupMethods
  include VersionMethods
  extend FactoryMethods
  include NoteMethods
  include TagMethods
  include BanMethods
  extend SearchMethods
  include ApiMethods

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

  def initialize_creator
    self.creator_id = CurrentUser.user.id
  end

  def deletable_by?(user)
    user.is_builder?
  end

  def editable_by?(user)
    user.is_builder? || (!is_banned? && is_active?)
  end

  def visible?
    !is_banned? || CurrentUser.is_gold?
  end
end
