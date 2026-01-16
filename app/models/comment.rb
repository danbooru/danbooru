# frozen_string_literal: true

class Comment < ApplicationRecord
  attr_accessor :creator_ip_addr

  belongs_to :post
  belongs_to :creator, class_name: "User"
  belongs_to :updater, class_name: "User", default: -> { creator }

  has_many :moderation_reports, as: :model, dependent: :destroy
  has_many :pending_moderation_reports, -> { pending }, as: :model, class_name: "ModerationReport"
  has_many :votes, class_name: "CommentVote", dependent: :destroy
  has_many :reactions, as: :model, dependent: :destroy, class_name: "Reaction"
  has_many :active_votes, -> { active }, class_name: "CommentVote"
  has_many :mod_actions, as: :subject, dependent: :destroy

  validates :body, visible_string: true, length: { maximum: 15_000 }, if: :body_changed?
  validate :validate_body, if: :body_changed?

  before_create :autoreport_spam
  before_save :handle_reports_on_deletion
  after_create :update_last_commented_at_on_create
  after_update(if: ->(comment) { (!comment.is_deleted? || !comment.saved_change_to_is_deleted?) && comment.updater != comment.creator }) do |comment|
    ModAction.log("updated #{comment.dtext_shortlink}", :comment_update, subject: self, user: comment.updater)
  end

  after_save :update_last_commented_at_on_destroy, :if => ->(rec) {rec.is_deleted? && rec.saved_change_to_is_deleted?}
  after_save(if: ->(comment) { comment.is_deleted? && comment.saved_change_to_is_deleted? && comment.updater != comment.creator }) do |comment|
    ModAction.log("deleted #{comment.dtext_shortlink}", :comment_delete, subject: self, user: comment.updater)
  end

  deletable
  dtext_attribute :body, media_embeds: { max_embeds: 1, max_large_emojis: 5, max_small_emojis: 100, max_video_size: 1.megabyte } # defines :dtext_body

  mentionable(
    message_field: :body,
    title: ->(_user_name) {"#{creator.name} mentioned you in a comment on post ##{post_id}"},
    body: lambda { |user_name|
      <<~EOF
        @#{creator.name} mentioned you in comment ##{id} on post ##{post_id}. This is an excerpt from the message:

        [quote]
        #{DText.new(body).extract_mention("@#{user_name}")}
        [/quote]
      EOF
    },
  )

  module SearchMethods
    def search(params, current_user)
      q = search_attributes(params, [:id, :created_at, :updated_at, :is_deleted, :is_sticky, :do_not_bump_post, :body, :score, :post, :creator, :updater], current_user: current_user)

      if params[:is_edited].to_s.truthy?
        q = q.where("comments.updated_at - comments.created_at > ?", 5.minutes.iso8601)
      elsif params[:is_edited].to_s.falsy?
        q = q.where("comments.updated_at - comments.created_at <= ?", 5.minutes.iso8601)
      end

      case params[:order]
      when "id_asc"
        q = q.order("comments.id ASC")
      when "created_at", "created_at_desc"
        q = q.order("comments.created_at DESC, comments.id DESC")
      when "created_at_asc"
        q = q.order("comments.created_at ASC, comments.id ASC")
      when "post_id", "post_id_desc"
        q = q.order("comments.post_id DESC, comments.id DESC")
      when "score", "score_desc"
        q = q.order("comments.score DESC, comments.id DESC")
      when "score_asc"
        q = q.order("comments.score ASC, comments.id ASC")
      when "updated_at", "updated_at_desc"
        q = q.order("comments.updated_at DESC, comments.id DESC")
      when "updated_at_asc"
        q = q.order("comments.updated_at ASC, comments.id ASC")
      else
        q = q.apply_default_order(params)
      end

      q
    end
  end

  extend SearchMethods

  def validate_body
    if (embedded_post = dtext_body.embedded_posts.find { |embedded_post| embedded_post.rating_id > post.rating_id })
      errors.add(:body, "can't include a #{embedded_post.pretty_rating.downcase} image on a #{post.pretty_rating.downcase} post")
    end

    if (embedded_asset = dtext_body.embedded_media_assets.find { |embedded_asset| embedded_asset.ai_rating_id > post.rating_id && embedded_asset.is_ai_nsfw? })
      errors.add(:body, "can't include a #{embedded_asset.pretty_ai_rating.downcase} image on a #{post.pretty_rating.downcase} post")
    end
  end

  def autoreport_spam
    if SpamDetector.new(self, user_ip: creator_ip_addr).spam?
      moderation_reports << ModerationReport.new(creator: User.system, reason: "Spam.")
    end
  end

  def update_last_commented_at_on_create
    Post.where(:id => post_id).update_all(:last_commented_at => created_at)
    if Comment.where(post_id: post_id).count <= Danbooru.config.comment_threshold && !do_not_bump_post?
      Post.where(:id => post_id).update_all(:last_comment_bumped_at => created_at)
    end
  end

  def update_last_commented_at_on_destroy
    other_comments = Comment.where("post_id = ? and id <> ?", post_id, id).order(id: :desc)
    if other_comments.count == 0
      Post.where(:id => post_id).update_all(:last_commented_at => nil)
    else
      Post.where(:id => post_id).update_all(:last_commented_at => other_comments.first.created_at)
    end

    other_comments = other_comments.where("do_not_bump_post = FALSE")
    if other_comments.count == 0
      Post.where(:id => post_id).update_all(:last_comment_bumped_at => nil)
    else
      Post.where(:id => post_id).update_all(:last_comment_bumped_at => other_comments.first.created_at)
    end
  end

  def handle_reports_on_deletion
    return unless Pundit.policy!(updater, ModerationReport).update?
    return unless moderation_reports.pending.present? && is_deleted_change == [false, true]

    moderation_reports.pending.update!(status: :handled, updater: updater)
  end

  def quoted_response
    DText.new(body).quote(self)
  end

  def self.available_includes
    [:post, :creator, :updater]
  end
end
