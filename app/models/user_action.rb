# frozen_string_literal: true

class UserAction < ApplicationRecord
  belongs_to :model, polymorphic: true
  belongs_to :user

  attribute :model_type, :string
  attribute :model_id, :integer
  attribute :user_id, :integer
  attribute :event_type, :string
  attribute :event_at, :datetime

  def self.model_types
    %w[ArtistVersion ArtistCommentaryVersion Ban BulkUpdateRequest Comment
       CommentVote Dmail FavoriteGroup ForumPost ForumPostVote ForumTopic
       ModAction ModerationReport NoteVersion Post PostAppeal PostApproval
       PostDisapproval PostFlag PostReplacement PostVote SavedSearch TagAlias
       TagImplication TagVersion Upload User UserEvent UserFeedback UserUpgrade
       UserNameChangeRequest WikiPageVersion]
  end

  def self.for_user(user)
    relations = [
      ArtistVersion.visible(user).select("'ArtistVersion'::character varying AS model_type, id AS model_id, updater_id AS user_id, 'create'::character varying AS event_type, created_at AS event_at"),
      ArtistCommentaryVersion.visible(user).select("'ArtistCommentaryVersion', id, updater_id, 'create', created_at"),
      Ban.visible(user).select("'Ban', id, user_id, 'subject', created_at"),
      BulkUpdateRequest.visible(user).select("'BulkUpdateRequest', id, user_id, 'create', created_at"),
      Comment.visible(user).select("'Comment', id, creator_id, 'create', created_at"),
      CommentVote.visible(user).select("'CommentVote', id, user_id, 'create', created_at"),
      Dmail.visible(user).sent.select("'Dmail', id, from_id, 'create', created_at").order(created_at: :desc),
      FavoriteGroup.visible(user).select("'FavoriteGroup', id, creator_id, 'create', created_at").order(created_at: :desc),
      ForumPost.visible(user).select("'ForumPost', id, creator_id, 'create', created_at").order(created_at: :desc),
      ForumPostVote.visible(user).select("'ForumPostVote', id, creator_id, 'create', created_at").order(created_at: :desc),
      ForumTopic.visible(user).select("'ForumTopic', id, creator_id, 'create', created_at"),
      ModAction.visible(user).select("'ModAction', id, creator_id, 'create', created_at"),
      ModerationReport.visible(user).select("'ModerationReport', id, creator_id, 'create', created_at"),
      NoteVersion.visible(user).select("'NoteVersion', id, updater_id, 'create', created_at"),
      Post.visible(user).select("'Post', id, uploader_id, 'create', created_at"),
      PostAppeal.visible(user).select("'PostAppeal', id, creator_id, 'create', created_at"),
      PostApproval.visible(user).select("'PostApproval', id, user_id, 'create', created_at"),
      PostDisapproval.visible(user).select("'PostDisapproval', id, user_id, 'create', created_at"),
      PostFlag.visible(user).visible_for_search(:creator, user).select("'PostFlag', id, creator_id, 'create', created_at"),
      PostReplacement.visible(user).select("'PostReplacement', id, creator_id, 'create', created_at"),
      PostVote.visible(user).select("'PostVote', id, user_id, 'create', created_at").order(created_at: :desc),
      SavedSearch.visible(user).select("'SavedSearch', id, user_id, 'create', created_at").order(created_at: :desc),
      TagAlias.visible(user).select("'TagAlias', id, creator_id, 'create', created_at"),
      TagImplication.visible(user).select("'TagImplication', id, creator_id, 'create', created_at"),
      TagVersion.visible(user).select("'TagVersion', id, updater_id, 'create', created_at").where.not(updater_id: nil).order(created_at: :desc),
      Upload.visible(user).select("'Upload', id, uploader_id, 'create', created_at").order(created_at: :desc),
      User.visible(user).select("'User', id, id, 'create', created_at"),
      UserEvent.visible(user).select("'UserEvent', id, user_id, 'create', created_at"),
      UserFeedback.visible(user).select("'UserFeedback', id, creator_id, 'create', created_at"),
      UserFeedback.visible(user).select("'UserFeedback', id, user_id, 'subject', created_at"),
      UserUpgrade.visible(user).select("'UserUpgrade', id, purchaser_id, 'create', created_at").where(status: [:complete, :refunded]).order(created_at: :desc),
      UserNameChangeRequest.visible(user).select("'UserNameChangeRequest', id, user_id, 'create', created_at"),
      WikiPageVersion.visible(user).select("'WikiPageVersion', id, updater_id, 'create', created_at"),
    ]

    union = relations.map(&:arel).reduce { |left, right| Arel::Nodes::UnionAll.new(left, right) }
    from(Arel::Nodes::TableAlias.new(union, "user_actions"))
  end

  def self.search(params, current_user)
    q = search_attributes(params, current_user: current_user)

    case params[:order]
    when "event_at_asc"
      q = q.order(event_at: :asc, model_id: :asc)
    else
      q = q.apply_default_order(params)
    end

    q
  end

  def self.default_order
    order(event_at: :desc, model_id: :desc)
  end

  def self.available_includes
    [:user, :model]
  end

  def readonly?
    true
  end
end
