class WikiPage < ApplicationRecord
  class RevertError < StandardError; end

  META_WIKIS = ["list_of_", "tag_group:", "pool_group:", "howto:", "about:", "help:", "template:"]

  before_save :normalize_title
  before_save :normalize_other_names
  before_save :update_dtext_links, if: :dtext_links_changed?
  after_save :create_version
  validates_uniqueness_of :title, :case_sensitive => false
  validates_presence_of :title
  validates_presence_of :body, :unless => -> { is_deleted? || other_names.present? }
  validate :validate_rename

  array_attribute :other_names
  has_one :tag, :foreign_key => "name", :primary_key => "title"
  has_one :artist, -> { active }, foreign_key: "name", primary_key: "title"
  has_many :versions, -> {order("wiki_page_versions.id ASC")}, :class_name => "WikiPageVersion", :dependent => :destroy
  has_many :dtext_links, as: :model, dependent: :destroy

  deletable

  module SearchMethods
    def find_by_id_or_title(id)
      if id =~ /\A\d+\z/
        [find_by_id(id), :id]
      else
        [find_by_title(normalize_title(id)), :title]
      end
    end

    def titled(title)
      where(title: normalize_title(title))
    end

    def other_names_include(name)
      name = normalize_other_name(name)
      subquery = WikiPage.from("unnest(other_names) AS other_name").where_iequals("other_name", name)
      where(id: subquery)
    end

    def other_names_match(name)
      if name =~ /\*/
        subquery = WikiPage.from("unnest(other_names) AS other_name").where_ilike("other_name", name)
        where(id: subquery)
      else
        other_names_include(name)
      end
    end

    def linked_to(title)
      where(dtext_links: DtextLink.wiki_page.wiki_link.where(link_target: normalize_title(title)))
    end

    def not_linked_to(title)
      where.not(dtext_links: DtextLink.wiki_page.wiki_link.where(link_target: normalize_title(title)))
    end

    def default_order
      order(updated_at: :desc)
    end

    def search(params = {})
      q = super

      q = q.search_attributes(params, :is_locked, :is_deleted, :body, :title, :other_names)
      q = q.text_attribute_matches(:body, params[:body_matches], index_column: :body_index, ts_config: "danbooru")

      if params[:title_normalize].present?
        q = q.where_like(:title, normalize_title(params[:title_normalize]))
      end

      if params[:other_names_match].present?
        q = q.other_names_match(params[:other_names_match])
      end

      if params[:linked_to].present?
        q = q.linked_to(params[:linked_to])
      end

      if params[:not_linked_to].present?
        q = q.not_linked_to(params[:not_linked_to])
      end

      if params[:hide_deleted].to_s.truthy?
        q = q.where("is_deleted = false")
      end

      if params[:other_names_present].to_s.truthy?
        q = q.where("other_names is not null and other_names != '{}'")
      elsif params[:other_names_present].to_s.falsy?
        q = q.where("other_names is null or other_names = '{}'")
      end

      case params[:order]
      when "title"
        q = q.order("title")
      when "post_count"
        q = q.includes(:tag).order("tags.post_count desc nulls last").references(:tags)
      else
        q = q.apply_default_order(params)
      end

      q
    end
  end

  extend SearchMethods

  def validate_rename
    return unless title_changed?

    tag_was = Tag.find_by_name(Tag.normalize_name(title_was))
    if tag_was.present? && !tag_was.empty?
      warnings[:base] << %!Warning: {{#{title_was}}} still has #{tag_was.post_count} #{"post".pluralize(tag_was.post_count)}. Be sure to move the posts!
    end

    broken_wikis = WikiPage.linked_to(title_was)
    if broken_wikis.count > 0
      broken_wiki_search = Rails.application.routes.url_helpers.wiki_pages_path(search: { linked_to: title_was })
      warnings[:base] << %!Warning: [[#{title_was}]] is still linked from "#{broken_wikis.count} #{"other wiki page".pluralize(broken_wikis.count)}":[#{broken_wiki_search}]. Update #{(broken_wikis.count > 1) ? "these wikis" : "this wiki"} to link to [[#{title}]] instead!
    end
  end

  def revert_to(version)
    if id != version.wiki_page_id
      raise RevertError.new("You cannot revert to a previous version of another wiki page.")
    end

    self.title = version.title
    self.body = version.body
    self.is_locked = version.is_locked
    self.other_names = version.other_names
  end

  def revert_to!(version)
    revert_to(version)
    save!
  end

  def self.normalize_title(title)
    return if title.blank?
    title.downcase.delete_prefix("~").gsub(/[[:space:]]+/, "_").gsub(/__/, "_").gsub(/\A_|_\z/, "")
  end

  def normalize_title
    self.title = WikiPage.normalize_title(title)
  end

  def normalize_other_names
    self.other_names = other_names.map { |name| WikiPage.normalize_other_name(name) }.uniq
  end

  def self.normalize_other_name(name)
    name.unicode_normalize(:nfkc).gsub(/[[:space:]]+/, " ").strip.tr(" ", "_")
  end

  def category_name
    tag&.category
  end

  def pretty_title
    title.tr("_", " ")
  end

  def self.is_meta_wiki?(title)
    title.present? && title.starts_with?(*META_WIKIS)
  end

  def is_meta_wiki?
    WikiPage.is_meta_wiki?(title)
  end

  def wiki_page_changed?
    saved_change_to_title? || saved_change_to_body? || saved_change_to_is_locked? || saved_change_to_is_deleted? || saved_change_to_other_names?
  end

  def merge_version
    prev = versions.last
    prev.update(title: title, body: body, is_locked: is_locked, is_deleted: is_deleted, other_names: other_names)
  end

  def merge_version?
    prev = versions.last
    prev && prev.updater_id == CurrentUser.id && prev.updated_at > 1.hour.ago
  end

  def create_new_version
    versions.create(
      :updater_id => CurrentUser.id,
      :updater_ip_addr => CurrentUser.ip_addr,
      :title => title,
      :body => body,
      :is_locked => is_locked,
      :is_deleted => is_deleted,
      :other_names => other_names
    )
  end

  def create_version
    if wiki_page_changed?
      if merge_version?
        merge_version
      else
        create_new_version
      end
    end
  end

  def dtext_links_changed?
    body_changed? && DText.dtext_links_differ?(body, body_was)
  end

  def update_dtext_links
    self.dtext_links = DtextLink.new_from_dtext(body)
  end

  def tags
    titles = DText.parse_wiki_titles(body).uniq
    tags = Tag.nonempty.where(name: titles).pluck(:name)
    tags += TagAlias.active.where(antecedent_name: titles).pluck(:antecedent_name)
    TagAlias.to_aliased(titles & tags)
  end

  def self.rewrite_wiki_links!(old_name, new_name)
    broken_wikis = WikiPage.linked_to(old_name)

    broken_wikis.each do |wiki|
      wiki.lock!
      wiki.body = DText.rewrite_wiki_links(wiki.body, old_name, new_name)
      wiki.save!
    end
  end

  def to_param
    if title =~ /\A\d+\z/
      "~#{title}"
    else
      title
    end
  end

  def self.model_restriction(table)
    super.where(table[:is_deleted].eq(false))
  end

  def self.searchable_includes
    [:tag, :artist, :dtext_links]
  end

  def self.available_includes
    [:tag, :artist, :dtext_links]
  end
end
