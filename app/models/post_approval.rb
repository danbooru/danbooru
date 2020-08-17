class PostApproval < ApplicationRecord
  belongs_to :user
  belongs_to :post, inverse_of: :approvals

  validate :validate_approval
  after_create :approve_post

  def validate_approval
    post.lock!

    if post.is_status_locked?
      errors.add(:post, "is locked and cannot be approved")
    end

    if post.is_active?
      errors.add(:post, "is already active and cannot be approved")
    end

    if post.uploader == user
      errors.add(:base, "You cannot approve a post you uploaded")
    end

    if post.approver == user || post.approvals.where(user: user).exists?
      errors.add(:base, "You have previously approved this post and cannot approve it again")
    end
  end

  def approve_post
    is_undeletion = post.is_deleted

    post.flags.pending.update!(status: :rejected)
    post.appeals.pending.update!(status: :succeeded)

    post.update(approver: user, is_flagged: false, is_pending: false, is_deleted: false)
    ModAction.log("undeleted post ##{post_id}", :post_undelete) if is_undeletion

    post.uploader.upload_limit.update_limit!(post, incremental: !is_undeletion)
  end

  def self.search(params)
    q = super
    q.apply_default_order(params)
  end

  def self.searchable_includes
    [:user, :post]
  end

  def self.available_includes
    [:user, :post]
  end
end
