# frozen_string_literal: true

class BanPolicy < ApplicationPolicy
  def bannable?
    user.is_moderator? && (record.user.blank? || (record.user.level < user.level))
  end

  alias_method :edit?, :bannable?
  alias_method :create?, :bannable?
  alias_method :update?, :bannable?
  alias_method :destroy?, :bannable?

  def permitted_attributes_for_create
    %i[reason duration user_id user_name delete_posts post_deletion_reason delete_comments delete_forum_posts delete_post_votes delete_comment_votes]
  end

  def permitted_attributes_for_update
    [:reason, :duration]
  end

  def html_data_attributes
    super + [:expired?]
  end
end
