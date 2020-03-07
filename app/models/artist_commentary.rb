class ArtistCommentary < ApplicationRecord
  class RevertError < StandardError; end

  attr_accessor :remove_commentary_tag, :remove_commentary_request_tag, :remove_commentary_check_tag, :remove_partial_commentary_tag
  attr_accessor :add_commentary_tag, :add_commentary_request_tag, :add_commentary_check_tag, :add_partial_commentary_tag
  before_validation :trim_whitespace
  validates_uniqueness_of :post_id
  belongs_to :post
  has_many :versions, -> {order("artist_commentary_versions.id ASC")}, :class_name => "ArtistCommentaryVersion", :dependent => :destroy, :foreign_key => :post_id, :primary_key => :post_id
  has_one :previous_version, -> {order(id: :desc)}, :class_name => "ArtistCommentaryVersion", :foreign_key => :post_id, :primary_key => :post_id
  after_save :create_version
  after_commit :tag_post

  module SearchMethods
    def text_matches(query)
      query = "*#{query}*" unless query =~ /\*/

      where_ilike(:original_title, query)
        .or(where_ilike(:original_description, query))
        .or(where_ilike(:translated_title, query))
        .or(where_ilike(:translated_description, query))
    end

    def deleted
      where(original_title: "", original_description: "", translated_title: "", translated_description: "")
    end

    def undeleted
      where("original_title != '' OR original_description != '' OR translated_title != '' OR translated_description != ''")
    end

    def search(params)
      q = super

      q = q.search_attributes(params, :post, :original_title, :original_description, :translated_title, :translated_description)

      if params[:text_matches].present?
        q = q.text_matches(params[:text_matches])
      end

      if params[:original_present].to_s.truthy?
        q = q.where("(original_title != '') or (original_description != '')")
      elsif params[:original_present].to_s.falsy?
        q = q.where("(original_title = '') and (original_description = '')")
      end

      if params[:translated_present].to_s.truthy?
        q = q.where("(translated_title != '') or (translated_description != '')")
      elsif params[:translated_present].to_s.falsy?
        q = q.where("(translated_title = '') and (translated_description = '')")
      end

      q = q.deleted if params[:is_deleted] == "yes"
      q = q.undeleted if params[:is_deleted] == "no"

      q.apply_default_order(params)
    end
  end

  def trim_whitespace
    self.original_title = original_title.gsub(/\A[[:space:]]+|[[:space:]]+\z/, "")
    self.translated_title = translated_title.gsub(/\A[[:space:]]+|[[:space:]]+\z/, "")
    self.original_description = original_description.gsub(/\A[[:space:]]+|[[:space:]]+\z/, "")
    self.translated_description = translated_description.gsub(/\A[[:space:]]+|[[:space:]]+\z/, "")
  end

  def original_present?
    original_title.present? || original_description.present?
  end

  def translated_present?
    translated_title.present? || translated_description.present?
  end

  def any_field_present?
    original_present? || translated_present?
  end

  def tag_post
    post.remove_tag("commentary") if remove_commentary_tag.to_s.truthy?
    post.add_tag("commentary") if add_commentary_tag.to_s.truthy?

    post.remove_tag("commentary_request") if remove_commentary_request_tag.to_s.truthy?
    post.add_tag("commentary_request") if add_commentary_request_tag.to_s.truthy?

    post.remove_tag("check_commentary") if remove_commentary_check_tag.to_s.truthy?
    post.add_tag("check_commentary") if add_commentary_check_tag.to_s.truthy?

    post.remove_tag("partial_commentary") if remove_partial_commentary_tag.to_s.truthy?
    post.add_tag("partial_commentary") if add_partial_commentary_tag.to_s.truthy?

    post.save if post.tag_string_changed?
  end

  module VersionMethods
    def create_version
      return unless saved_changes?

      if merge_version?
        merge_version
      else
        create_new_version
      end
    end

    def merge_version?
      previous_version && previous_version.updater == CurrentUser.user && previous_version.updated_at > 1.hour.ago
    end

    def merge_version
      previous_version.update(
        original_title: original_title,
        original_description: original_description,
        translated_title: translated_title,
        translated_description: translated_description
      )
    end

    def create_new_version
      versions.create(
        :original_title => original_title,
        :original_description => original_description,
        :translated_title => translated_title,
        :translated_description => translated_description
      )
    end

    def revert_to(version)
      if post_id != version.post_id
        raise RevertError.new("You cannot revert to a previous artist commentary of another post.")
      end

      self.original_description = version.original_description
      self.original_title = version.original_title
      self.translated_description = version.translated_description
      self.translated_title = version.translated_title
    end

    def revert_to!(version)
      revert_to(version)
      save!
    end
  end

  extend SearchMethods
  include VersionMethods

  def self.available_includes
    [:post]
  end
end
