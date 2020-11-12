class Artist < ApplicationRecord
  extend Memoist
  class RevertError < StandardError; end

  attr_accessor :url_string_changed
  array_attribute :other_names
  deletable

  before_validation :normalize_name
  before_validation :normalize_other_names
  validate :validate_tag_category
  validates :name, tag_name: true, uniqueness: true
  before_save :update_tag_category
  after_save :create_version
  after_save :clear_url_string_changed

  has_many :members, :class_name => "Artist", :foreign_key => "group_name", :primary_key => "name"
  has_many :urls, :dependent => :destroy, :class_name => "ArtistUrl", :autosave => true
  has_many :versions, -> {order("artist_versions.id ASC")}, :class_name => "ArtistVersion"
  has_one :wiki_page, :foreign_key => "title", :primary_key => "name"
  has_one :tag_alias, :foreign_key => "antecedent_name", :primary_key => "name"
  belongs_to :tag, foreign_key: "name", primary_key: "name", default: -> { Tag.new(name: name, category: Tag.categories.artist) }

  scope :banned, -> { where(is_banned: true) }
  scope :unbanned, -> { where(is_banned: false) }

  module UrlMethods
    extend ActiveSupport::Concern

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
      if saved_change_to_name? || url_string_changed || saved_change_to_is_deleted? || saved_change_to_is_banned? || saved_change_to_other_names? || saved_change_to_group_name? || force
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
        :is_deleted => is_deleted,
        :is_banned => is_banned,
        :other_names => other_names,
        :group_name => group_name
      )
    end

    def merge_version
      prev = versions.last
      prev.update(name: name, urls: url_array, is_deleted: is_deleted, is_banned: is_banned, other_names: other_names, group_name: group_name)
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
      self.is_deleted = version.is_deleted
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
        post = Post.system_tag_match("source:http* #{params[:name]}").first
        source = post.try(:source)
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

  module TagMethods
    def validate_tag_category
      return unless !is_deleted? && name_changed? && tag.present?

      if tag.category_name != "Artist" && !tag.empty?
        errors[:base] << "'#{name}' is a #{tag.category_name.downcase} tag; artist entries can only be created for artist tags"
      end
    end

    def update_tag_category
      return unless !is_deleted? && name_changed? && tag.present?

      if tag.category_name != "Artist" && tag.empty?
        tag.update!(category: Tag.categories.artist)
      end
    end
  end

  module BanMethods
    def unban!
      Post.transaction do
        ti = TagImplication.find_by(antecedent_name: name, consequent_name: "banned_artist")
        ti&.destroy

        Post.raw_tag_match(name).find_each do |post|
          post.unban!
          fixed_tags = post.tag_string.sub(/(?:\A| )banned_artist(?:\Z| )/, " ").strip
          post.update(tag_string: fixed_tags)
        end

        update!(is_banned: false)
        ModAction.log("unbanned artist ##{id}", :artist_unban)
      end
    end

    def ban!(banner: CurrentUser.user)
      Post.transaction do
        Post.raw_tag_match(name).each(&:ban!)

        # potential race condition but unlikely
        unless TagImplication.where(:antecedent_name => name, :consequent_name => "banned_artist").exists?
          tag_implication = TagImplication.create!(antecedent_name: name, consequent_name: "banned_artist", skip_secondary_validations: true, creator: banner)
          tag_implication.approve!(banner)
        end

        update!(is_banned: true)
        ModAction.log("banned artist ##{id}", :artist_ban)
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
      query = query.strip

      if query =~ %r!\A/(.*)/\z!
        where(id: ArtistUrl.where_regex(:url, $1).select(:artist_id))
      elsif query.include?("*")
        where(id: ArtistUrl.where_like(:url, query).select(:artist_id))
      elsif query =~ %r!\Ahttps?://!i
        ArtistFinder.find_artists(query)
      else
        where(id: ArtistUrl.where_like(:url, "*#{query}*").select(:artist_id))
      end
    end

    def any_name_or_url_matches(query)
      query = query.strip

      if query =~ %r!\Ahttps?://!i
        url_matches(query)
      else
        any_name_matches(query)
      end
    end

    def search(params)
      q = super

      q = q.search_attributes(params, :is_deleted, :is_banned, :name, :group_name, :other_names)

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

      case params[:order]
      when "name"
        q = q.order("artists.name")
      when "updated_at"
        q = q.order("artists.updated_at desc")
      when "post_count"
        q = q.left_outer_joins(:tag).order("tags.post_count desc nulls last").order("artists.name")
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
  include TagMethods
  include BanMethods
  extend SearchMethods

  def self.model_restriction(table)
    super.where(table[:is_deleted].eq(false))
  end

  def self.searchable_includes
    [:urls, :wiki_page, :tag_alias, :tag]
  end

  def self.available_includes
    [:members, :urls, :wiki_page, :tag_alias, :tag]
  end
end
