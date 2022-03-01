# frozen_string_literal: true

class WikiPage < ApplicationRecord
  class RevertError < StandardError; end

  META_WIKIS = ["list_of_", "tag_group:", "pool_group:", "howto:", "about:", "help:", "template:"]

  after_save :create_version

  normalize :title, :normalize_title
  normalize :body, :normalize_text
  normalize :other_names, :normalize_other_names

  array_attribute :other_names # XXX must come after `normalize :other_names`

  validates :title, tag_name: true, presence: true, uniqueness: true, if: :title_changed?
  validates :body, presence: true, unless: -> { is_deleted? || other_names.present? }
  validate :validate_rename
  validate :validate_other_names

  has_one :tag, :foreign_key => "name", :primary_key => "title"
  has_one :artist, -> { active }, foreign_key: "name", primary_key: "title"
  has_many :versions, -> {order("wiki_page_versions.id ASC")}, :class_name => "WikiPageVersion", :dependent => :destroy

  deletable
  has_dtext_links :body

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

    def title_matches(title)
      where_like(:title, normalize_title(title))
    end

    def other_names_include(name)
      name = normalize_other_name(name)
      subquery = WikiPage.from("unnest(other_names) AS other_name").where_iequals("other_name", name)
      where(id: subquery)
    end

    def other_names_match(name)
      if name =~ /\*/
        subquery = WikiPage.from("unnest(other_names) AS other_name").where_ilike("other_name", normalize_other_name(name))
        where(id: subquery)
      else
        other_names_include(name)
      end
    end

    def default_order
      order(updated_at: :desc)
    end

    def search(params = {})
      q = search_attributes(params, :id, :created_at, :updated_at, :is_locked, :is_deleted, :body, :title, :other_names, :tag, :artist, :dtext_links)
      q = q.text_attribute_matches(:body, params[:body_matches])
      q = q.text_attribute_matches([:title, :body], params[:title_or_body_matches])

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
        q = q.order(title: :asc)
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
      warnings.add(:base, %{Warning: {{#{title_was}}} still has #{tag_was.post_count} #{"post".pluralize(tag_was.post_count)}. Be sure to move the posts})
    end

    broken_wikis = WikiPage.linked_to(title_was)
    if broken_wikis.count > 0
      broken_wiki_search = Routes.wiki_pages_path(search: { linked_to: title_was })
      warnings.add(:base, %{Warning: [[#{title_was}]] is still linked from "#{broken_wikis.count} #{"other wiki page".pluralize(broken_wikis.count)}":[#{broken_wiki_search}]. Update #{(broken_wikis.count > 1) ? "these wikis" : "this wiki"} to link to [[#{title}]] instead})
    end
  end

  def validate_other_names
    if other_names.present? && tag&.artist?
      errors.add(:base, "An artist wiki can't have other names")
    end
  end

  def revert_to(version)
    if id != version.wiki_page_id
      raise RevertError, "You cannot revert to a previous version of another wiki page."
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
    title.to_s.downcase.delete_prefix("~").gsub(/[[:space:]]+/, "_").squeeze("_").gsub(/\A_|_\z/, "")
  end

  def self.normalize_other_names(other_names)
    other_names.map { |name| normalize_other_name(name) }.uniq.reject(&:blank?)
  end

  def self.normalize_other_name(name)
    name.to_s.unicode_normalize(:nfkc).normalize_whitespace.gsub(/[[:space:]]+/, "_").squeeze("_").gsub(/\A_|_\z/, "")
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

  def tags
    titles = DText.parse_wiki_titles(body).uniq
    tags = Tag.nonempty.where(name: titles).pluck(:name)
    tags += TagAlias.active.where(antecedent_name: titles).pluck(:antecedent_name)
    TagAlias.to_aliased(titles & tags)
  end

  def self.rewrite_wiki_links!(old_name, new_name)
    WikiPage.linked_to(old_name).each do |wiki|
      wiki.lock!.update!(body: DText.rewrite_wiki_links(wiki.body, old_name, new_name))
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

  def self.available_includes
    [:tag, :artist, :dtext_links]
  end
end
