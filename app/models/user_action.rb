# frozen_string_literal: true

class UserAction < ApplicationRecord
  belongs_to :model, polymorphic: true
  belongs_to :user

  attribute :model_type, :string
  attribute :model_id, :integer
  attribute :user_id, :integer
  attribute :event_type, :string
  attribute :event_at, :time

  def self.model_types
    %w[ArtistVersion ArtistCommentaryVersion Ban BulkUpdateRequest Comment
    CommentVote Dmail FavoriteGroup ForumPost ForumPostVote ForumTopic
    ModAction ModerationReport NoteVersion Post PostAppeal PostApproval
    PostDisapproval PostFlag PostReplacement PostVote SavedSearch TagAlias
    TagImplication TagVersion Upload User UserEvent UserFeedback UserUpgrade
    UserNameChangeRequest WikiPageVersion AIMetadataVersion]
  end

  def self.for_user(user)
    sql = <<~SQL.squish
    (#{AIMetadataVersion.visible(user).select("'AIMetadataVersion'::character varying AS model_type, id AS model_id, updater_id AS user_id, 'create'::character varying AS event_type, created_at AS event_at").to_sql})
    UNION ALL
      (#{ArtistVersion.visible(user).select("'ArtistVersion'::character varying AS model_type, id AS model_id, updater_id AS user_id, 'create'::character varying AS event_type, created_at AS event_at").to_sql})
    UNION ALL
      (#{ArtistCommentaryVersion.visible(user).select("'ArtistCommentaryVersion', id, updater_id, 'create', created_at").to_sql})
    UNION ALL
      (#{Ban.visible(user).select("'Ban', id, user_id, 'subject', created_at").to_sql})
    UNION ALL
      (#{BulkUpdateRequest.visible(user).select("'BulkUpdateRequest', id, user_id, 'create', created_at").to_sql})
    UNION ALL
      (#{Comment.visible(user).select("'Comment', id, creator_id, 'create', created_at").to_sql})
    UNION ALL
      (#{CommentVote.visible(user).select("'CommentVote', id, user_id, 'create', created_at").to_sql})
    UNION ALL
      (#{Dmail.visible(user).sent.select("'Dmail', id, from_id, 'create', created_at").order(created_at: :desc).to_sql})
    UNION ALL
      (#{FavoriteGroup.visible(user).select("'FavoriteGroup', id, creator_id, 'create', created_at").order(created_at: :desc).to_sql})
    UNION ALL
      (#{ForumPost.visible(user).select("'ForumPost', id, creator_id, 'create', created_at").order(created_at: :desc).to_sql})
    UNION ALL
      (#{ForumPostVote.visible(user).select("'ForumPostVote', id, creator_id, 'create', created_at").order(created_at: :desc).to_sql})
    UNION ALL
      (#{ForumTopic.visible(user).select("'ForumTopic', id, creator_id, 'create', created_at").to_sql})
    UNION ALL
      (#{ModAction.visible(user).select("'ModAction', id, creator_id, 'create', created_at").to_sql})
    UNION ALL
      (#{ModerationReport.visible(user).select("'ModerationReport', id, creator_id, 'create', created_at").to_sql})
    UNION ALL
      (#{NoteVersion.visible(user).select("'NoteVersion', id, updater_id, 'create', created_at").to_sql})
    UNION ALL
      (#{Post.visible(user).select("'Post', id, uploader_id, 'create', created_at").to_sql})
    UNION ALL
      (#{PostAppeal.visible(user).select("'PostAppeal', id, creator_id, 'create', created_at").to_sql})
    UNION ALL
      (#{PostApproval.visible(user).select("'PostApproval', id, user_id, 'create', created_at").to_sql})
    UNION ALL
      (#{PostDisapproval.visible(user).select("'PostDisapproval', id, user_id, 'create', created_at").to_sql})
    UNION ALL
      (#{PostFlag.visible(user).select("'PostFlag', id, creator_id, 'create', created_at").to_sql})
    UNION ALL
      (#{PostReplacement.visible(user).select("'PostReplacement', id, creator_id, 'create', created_at").to_sql})
    UNION ALL
      (#{PostVote.visible(user).select("'PostVote', id, user_id, 'create', created_at").order(created_at: :desc).to_sql})
    UNION ALL
      (#{SavedSearch.visible(user).select("'SavedSearch', id, user_id, 'create', created_at").order(created_at: :desc).to_sql})
    UNION ALL
      (#{TagAlias.visible(user).select("'TagAlias', id, creator_id, 'create', created_at").to_sql})
    UNION ALL
      (#{TagImplication.visible(user).select("'TagImplication', id, creator_id, 'create', created_at").to_sql})
    UNION ALL
      (#{TagVersion.visible(user).select("'TagVersion', id, updater_id, 'create', created_at").where("updater_id IS NOT NULL").order(created_at: :desc).to_sql})
    UNION ALL
      (#{Upload.visible(user).select("'Upload', id, uploader_id, 'create', created_at").order(created_at: :desc).to_sql})
    UNION ALL
      (#{User.visible(user).select("'User', id, id, 'create', created_at").to_sql})
    UNION ALL
      (#{UserEvent.visible(user).select("'UserEvent', id, user_id, 'create', created_at").to_sql})
    UNION ALL
      (#{UserFeedback.visible(user).select("'UserFeedback', id, creator_id, 'create', created_at").to_sql})
    UNION ALL
      (#{UserFeedback.visible(user).select("'UserFeedback', id, user_id, 'subject', created_at").to_sql})
    UNION ALL (
      (#{UserUpgrade.visible(user).select("'UserUpgrade', id, purchaser_id, 'create', created_at").where(status: [:complete, :refunded]).order(created_at: :desc).to_sql})
    ) UNION ALL
      (#{UserNameChangeRequest.visible(user).select("'UserNameChangeRequest', id, user_id, 'create', created_at").to_sql})
    UNION ALL
      (#{WikiPageVersion.visible(user).select("'WikiPageVersion', id, updater_id, 'create', created_at").to_sql})
    SQL

    from("(#{sql}) user_actions")
  end

  def self.visible(user)
    all
  end

  def self.search(params, current_user)
    q = search_attributes(params, [:event_type, :user, :model], current_user: current_user)

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
