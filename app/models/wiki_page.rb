class WikiPage < ApplicationRecord
  class RevertError < Exception ; end

  before_save :normalize_title
  before_save :normalize_other_names
  before_validation :initialize_creator, :on => :create
  before_validation :initialize_updater
  after_save :create_version
  belongs_to :creator, :class_name => "User"
  belongs_to :updater, :class_name => "User"
  validates_uniqueness_of :title, :case_sensitive => false
  validates_presence_of :title
  validates_presence_of :body, :unless => -> { is_deleted? || other_names.present? }
  validate :validate_rename
  validate :validate_not_locked
  attr_accessor :skip_secondary_validations
  has_one :tag, :foreign_key => "name", :primary_key => "title"
  has_one :artist, lambda {where(:is_active => true)}, :foreign_key => "name", :primary_key => "title"
  has_many :versions, lambda {order("wiki_page_versions.id ASC")}, :class_name => "WikiPageVersion", :dependent => :destroy

  module SearchMethods
    def titled(title)
      where("title = ?", title.mb_chars.downcase.tr(" ", "_"))
    end

    def title_in(titles)
      where("title in (?)", titles.map{|x| x.mb_chars.downcase.tr(" ", "_")} )
    end

    def active
      where("is_deleted = false")
    end

    def recent
      order("updated_at DESC").limit(25)
    end

    def body_matches(query)
      if query =~ /\*/ && CurrentUser.user.is_builder?
        where("body ILIKE ? ESCAPE E'\\\\'", query.to_escaped_for_sql_like)
      else
        where("body_index @@ plainto_tsquery(?)", query.to_escaped_for_tsquery_split)
      end
    end

    def other_names_equal(name)
      query_sql = name.unicode_normalize(:nfkc).to_escaped_for_tsquery
      where("other_names_index @@ to_tsquery('danbooru', E?)", query_sql)
    end

    def other_names_match(name)
      if name =~ /\*/
        subquery = WikiPage.from("unnest(string_to_array(other_names, ' ')) AS other_name").where("other_name ILIKE ?", name.to_escaped_for_sql_like)
        where(id: subquery)
      else
        other_names_equal(name)
      end
    end

    def default_order
      order(updated_at: :desc)
    end

    def search(params = {})
      q = super

      if params[:title].present?
        q = q.where("title LIKE ? ESCAPE E'\\\\'", params[:title].mb_chars.downcase.tr(" ", "_").to_escaped_for_sql_like)
      end

      if params[:creator_id].present?
        q = q.where("creator_id = ?", params[:creator_id])
      end

      if params[:body_matches].present?
        q = q.body_matches(params[:body_matches])
      end

      if params[:other_names_match].present?
        q = q.other_names_match(params[:other_names_match])
      end

      if params[:creator_name].present?
        q = q.where("creator_id = (select _.id from users _ where lower(_.name) = ?)", params[:creator_name].tr(" ", "_").mb_chars.downcase)
      end

      if params[:hide_deleted] =~ /y/i
        q = q.where("is_deleted = false")
      end

      if params[:other_names_present] == "yes"
        q = q.where("other_names is not null and other_names != ''")
      elsif params[:other_names_present] == "no"
        q = q.where("other_names is null or other_names = ''")
      end

      params[:order] ||= params.delete(:sort)
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

  module ApiMethods
    def hidden_attributes
      super + [:body_index, :other_names_index]
    end

    def method_attributes
      super + [:creator_name, :category_name]
    end
  end

  extend SearchMethods
  include ApiMethods

  def self.find_title_and_id(title)
    titled(title).select("title, id").first
  end

  def validate_not_locked
    if is_locked? && !CurrentUser.is_builder?
      errors.add(:is_locked, "and cannot be updated")
      return false
    end
  end

  def validate_rename
    return if !title_changed? || skip_secondary_validations

    tag_was = Tag.find_by_name(Tag.normalize_name(title_was))
    if tag_was.present? && tag_was.post_count > 0
      errors.add(:title, "cannot be changed: '#{tag_was.name}' still has #{tag_was.post_count} posts. Move the posts and update any wikis linking to this page first.")
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

  def normalize_title
    self.title = title.mb_chars.downcase.tr(" ", "_")
  end

  def normalize_other_names
    normalized_other_names = other_names.to_s.unicode_normalize(:nfkc).scan(/[^[:space:]]+/)
    self.other_names = normalized_other_names.uniq.join(" ")
  end

  def skip_secondary_validations=(value)
    @skip_secondary_validations = (value == true || value == "1")
  end

  def creator_name
    User.id_to_name(creator_id)
  end

  def category_name
    Tag.category_for(title)
  end

  def pretty_title
    title.tr("_", " ")
  end

  def wiki_page_changed?
    title_changed? || body_changed? || is_locked_changed? || is_deleted_changed? || other_names_changed?
  end

  def merge_version
    prev = versions.last
    prev.update_attributes(
      :title => title,
      :body => body,
      :is_locked => is_locked,
      :is_deleted => is_deleted,
      :other_names => other_names
    )
  end

  def merge_version?
    prev = versions.last
    prev && prev.updater_id == CurrentUser.user.id && prev.updated_at > 1.hour.ago
  end

  def create_new_version
    versions.create(
      :updater_id => CurrentUser.user.id,
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
  
  def updater_name
    User.id_to_name(updater_id)
  end

  def initialize_creator
    self.creator_id = CurrentUser.user.id
  end

  def initialize_updater
    if wiki_page_changed?
      self.updater_id = CurrentUser.user.id
    end
  end

  def post_set
    @post_set ||= PostSets::WikiPage.new(title, 1, 4)
  end

  def presenter
    @presenter ||= WikiPagePresenter.new(self)
  end

  def tags
    body.scan(/\[\[(.+?)\]\]/).flatten.map do |match|
      if match =~ /^(.+?)\|(.+)/
        $1
      else
        match
      end
    end.map {|x| x.mb_chars.downcase.tr(" ", "_").to_s}.uniq
  end

  def visible?
    artist.blank? || !artist.is_banned? || CurrentUser.is_builder?
  end

  def other_names_array
    other_names.to_s.scan(/\S+/)
  end
end
