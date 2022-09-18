# frozen_string_literal: true

class Comment < ApplicationRecord
  self.ignored_columns = [:creator_ip_addr, :updater_ip_addr]

  attr_accessor :creator_ip_addr

  belongs_to :post
  belongs_to :creator, class_name: "User"
  belongs_to_updater

  has_many :moderation_reports, as: :model, dependent: :destroy
  has_many :pending_moderation_reports, -> { pending }, as: :model, class_name: "ModerationReport"
  has_many :votes, class_name: "CommentVote", dependent: :destroy

  validates :body, presence: true, length: { maximum: 15_000 }, if: :body_changed?

  before_create :autoreport_spam
  before_save :handle_reports_on_deletion
  after_create :update_last_commented_at_on_create
  after_update(:if => ->(rec) {(!rec.is_deleted? || !rec.saved_change_to_is_deleted?) && CurrentUser.id != rec.creator_id}) do |rec|
    ModAction.log("comment ##{rec.id} updated by #{CurrentUser.user.name}", :comment_update)
  end
  after_save :update_last_commented_at_on_destroy, :if => ->(rec) {rec.is_deleted? && rec.saved_change_to_is_deleted?}
  after_save(:if => ->(rec) {rec.is_deleted? && rec.saved_change_to_is_deleted? && CurrentUser.id != rec.creator_id}) do |rec|
    ModAction.log("comment ##{rec.id} deleted by #{CurrentUser.user.name}", :comment_delete)
  end

  deletable
  mentionable(
    message_field: :body,
    title: ->(_user_name) {"#{creator.name} mentioned you in a comment on post ##{post_id}"},
    body: ->(user_name) {"@#{creator.name} mentioned you in comment ##{id} on post ##{post_id}:\n\n[quote]\n#{DText.extract_mention(body, "@#{user_name}")}\n[/quote]\n"}
  )

  module SearchMethods
    def search(params)
      q = search_attributes(params, :id, :created_at, :updated_at, :is_deleted, :is_sticky, :do_not_bump_post, :body, :score, :post, :creator, :updater)
      q = q.text_attribute_matches(:body, params[:body_matches])

      case params[:order]
      when "post_id", "post_id_desc"
        q = q.order("comments.post_id DESC, comments.id DESC")
      when "score", "score_desc"
        q = q.order("comments.score DESC, comments.id DESC")
      when "updated_at", "updated_at_desc"
        q = q.order("comments.updated_at DESC")
      else
        q = q.apply_default_order(params)
      end

      q
    end
  end

  extend SearchMethods

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
    DText.quote(body, creator.name)
  end

  def self.available_includes
    [:post, :creator, :updater]
  end
end
