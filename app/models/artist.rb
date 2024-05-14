# frozen_string_literal: true

class Artist < ApplicationRecord
  extend Memoist
  class RevertError < StandardError; end

  attr_accessor :url_string_changed

  deletable

  normalize :name, :normalize_name
  normalize :group_name, :normalize_other_name
  normalize :other_names, :normalize_other_names
  array_attribute :other_names # XXX must come after `normalize :other_names`

  validate :validate_artist_name
  validates :name, tag_name: true, uniqueness: true
  after_validation :add_url_warnings

  before_save :update_tag_category
  after_save :create_version
  after_save :clear_url_string_changed

  has_many :members, :class_name => "Artist", :foreign_key => "group_name", :primary_key => "name"
  has_many :urls, dependent: :destroy, class_name: "ArtistURL", autosave: true
  has_many :versions, -> {order("artist_versions.id ASC")}, :class_name => "ArtistVersion"
  has_many :mod_actions, as: :subject, dependent: :destroy
  has_one :wiki_page, -> { active }, foreign_key: "title", primary_key: "name"
  has_one :tag_alias, -> { active }, foreign_key: "antecedent_name", primary_key: "name"
  belongs_to :tag, foreign_key: "name", primary_key: "name", default: -> { Tag.new(name: name, category: Tag.categories.artist) }

  scope :banned, -> { where(is_banned: true) }
  scope :unbanned, -> { where(is_banned: false) }

  module UrlMethods
    extend ActiveSupport::Concern

    def sorted_urls
      Danbooru.natural_sort_by(urls, &:url).sort_by.with_index do |url, i|
        [url.is_active? ? 0 : 1, url.priority, url.domain, url.secondary_url? ? 1 : 0, i]
      end
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
        is_active, url = ArtistURL.parse_prefix(url)
        self.urls.find_or_initialize_by(url: url, is_active: is_active)
      end.uniq(&:url)

      self.url_string_changed = (url_string_was != url_string)
    end

    def clear_url_string_changed
      self.url_string_changed = false
    end

    class_methods do
      # Find all artist URLs matching `regex`, and replace the `from` regex with the `to` string.
      def rewrite_urls(regex, from, to)
        Artist.joins(:urls).where_regex("artist_urls.url", regex).find_each do |artist|
          artist.update!(url_string: artist.url_string.gsub(from, to))
        end
      end
    end
  end

  concerning :NameMethods do
    class_methods do
      def normalize_name(name)
        name.to_s.downcase.strip.gsub(/ /, "_").to_s
      end

      def normalize_other_names(other_names)
        other_names.map { |name| normalize_other_name(name) }.uniq.reject(&:blank?)
      end

      # XXX Differences from wiki page other names: allow uppercase, use NFC
      # instead of NFKC, and allow repeated, leading, and trailing underscores.
      def normalize_other_name(other_name)
        other_name.to_s.unicode_normalize(:nfc).normalize_whitespace.squish.tr(" ", "_")
      end
    end

    def pretty_name
      name.tr("_", " ")
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
        artist = Source::Extractor.find(source).new_artist
        artist.attributes = params
      else
        artist = Artist.new(params)
      end

      artist
    end
  end

  module TagMethods
    def validate_artist_name
      return unless !is_deleted? && name_changed?

      if tag.present? && tag.category_name != "Artist" && !tag.empty?
        errors.add(:name, "'#{name}' is a #{tag.category_name.downcase} tag; artist entries can only be created for artist tags")
      end

      if tag&.is_deprecated?
        errors.add(:name, "'#{name}' is an ambiguous tag; try another name")
      end

      if tag_alias.present?
        errors.add(:name, "'#{name}' is aliased to '#{tag_alias.consequent_name}'")
      end
    end

    def update_tag_category
      return unless !is_deleted? && name_changed? && tag.present?

      if tag.category_name != "Artist" && tag.empty?
        tag.update!(category: Tag.categories.artist, updater: CurrentUser.user)
      end
    end
  end

  module BanMethods
    def unban!(current_user)
      with_lock do
        ti = TagImplication.active.find_by(antecedent_name: name, consequent_name: "banned_artist")
        ti&.update!(status: "deleted")

        BulkUpdateRequestProcessor.mass_update(name, "-status:banned -banned_artist", user: current_user)

        CurrentUser.scoped(current_user) { update!(is_banned: false) }
        ModAction.log("unbanned artist ##{id}", :artist_unban, subject: self, user: current_user)
      end
    end

    def ban!(banner)
      with_lock do
        BulkUpdateRequestProcessor.mass_update(name, "status:banned", user: banner)

        unless TagImplication.active.exists?(antecedent_name: name, consequent_name: "banned_artist")
          Tag.find_or_create_by_name("banned_artist", category: "artist", current_user: banner)
          TagImplication.approve!(antecedent_name: name, consequent_name: "banned_artist", approver: banner)
        end

        CurrentUser.scoped(banner) { update!(is_banned: true) }
        ModAction.log("banned artist ##{id}", :artist_ban, subject: self, user: banner)
      end
    end
  end

  module SearchMethods
    def name_matches(query)
      where_like(:name, normalize_name(query))
    end

    def any_other_name_matches(regex)
      where(id: Artist.from("unnest(other_names) AS other_name").where_regex("other_name", regex))
    end

    def any_other_name_like(name)
      where(id: Artist.from("unnest(other_names) AS other_name").where_ilike("other_name", name))
    end

    def any_name_matches(query)
      if query =~ %r{\A/(.*)/\z}
        where_regex(:name, $1).or(any_other_name_matches($1)).or(where_regex(:group_name, $1))
      elsif query.include?("*")
        normalized_name = normalize_name(query)
        where_ilike(:name, normalized_name).or(any_other_name_like(normalized_name)).or(where_ilike(:group_name, normalized_name))
      else
        normalized_name = normalize_name(query)
        where_array_includes_any("lower(ARRAY[artists.name, artists.group_name]::text[] || artists.other_names)", [normalized_name])
      end
    end

    def urls_match(urls)
      urls = Array.wrap(urls).flat_map(&:split)
      return all if urls.empty?

      urls.map do |url|
        url_matches(url)
      end.reduce(&:or)
    end

    def url_matches(query)
      query = query.strip

      if query =~ %r{\Ahttps?://}i
        Source::Extractor.find(query).artists
      else
        where(id: ArtistURL.url_matches(query).select(:artist_id))
      end
    end

    def has_normalized_url(urls)
      where(id: ArtistURL.normalized_url_equals_any(urls).select(:artist_id))
    end

    def any_name_or_url_matches(query)
      query = query.strip

      if query =~ %r{\Ahttps?://}i
        url_matches(query)
      else
        any_name_matches(query)
      end
    end

    def search(params, current_user)
      q = search_attributes(params, [:id, :created_at, :updated_at, :is_deleted, :is_banned, :name, :group_name, :other_names, :urls, :wiki_page, :tag_alias, :tag], current_user: current_user)

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
        q = q.urls_match(params[:url_matches])
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

  def add_url_warnings
    urls.each do |url|
      warnings.add(:base, url.warnings.full_messages.join("; ")) if url.warnings.any?
    end
  end

  include UrlMethods
  include VersionMethods
  extend FactoryMethods
  include TagMethods
  include BanMethods
  extend SearchMethods

  def self.model_restriction(table)
    super.where(table[:is_deleted].eq(false))
  end

  def self.available_includes
    [:members, :urls, :wiki_page, :tag_alias, :tag]
  end
end
