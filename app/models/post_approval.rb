# frozen_string_literal: true

class PostApproval < ApplicationRecord
  belongs_to :user
  belongs_to :post, inverse_of: :approvals

  validate :validate_approval
  after_create :approve_post

  def validate_approval
    post.lock!

    if post.is_active?
      errors.add(:post, "is already active and cannot be approved")
    end

    if post.uploader == user && !policy(user).can_approve_own_uploads?
      errors.add(:base, "You cannot approve a post you uploaded")
    end

    if (post.approver == user || post.approvals.exists?(user: user)) && !policy(user).can_approve_same_post_twice?
      errors.add(:base, "You have previously approved this post and cannot approve it again")
    end
  end

  def approve_post
    is_pending = post.is_pending
    is_undeletion = post.is_deleted

    post.flags.pending.update!(status: :rejected)
    post.appeals.pending.update!(status: :succeeded)

    post.update(approver: user, is_flagged: false, is_pending: false, is_deleted: false)
    ModAction.log("undeleted post ##{post_id}", :post_undelete, subject: post, user: user) if is_undeletion

    post.uploader.upload_limit.update_limit!(is_pending, true)
  end

  def self.search(params, current_user)
    q = search_attributes(params, [:id, :created_at, :updated_at, :user, :post], current_user: current_user)
    q.apply_default_order(params)
  end

  def self.available_includes
    [:user, :post]
  end
end
