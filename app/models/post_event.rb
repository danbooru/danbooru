class PostEvent
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  include ActiveModel::Serializers::Xml

  attr_accessor :event
  delegate :created_at, to: :event

  def self.find_for_post(post_id)
    post = Post.find(post_id)
    (post.appeals + post.flags + post.approvals).sort_by(&:created_at).reverse.map { |e| new(event: e) }
  end

  def type_name
    case event
    when PostFlag
      "flag"
    when PostAppeal
      "appeal"
    when PostApproval
      "approval"
    end
  end

  def type
    type_name.first
  end

  def reason
    event.try(:reason) || ""
  end

  def creator_id
    event.try(:creator_id) || event.try(:user_id)
  end

  def creator
    event.try(:creator) || event.try(:user)
  end

  def status
    if event.is_a?(PostApproval)
      "approved"
    elsif (event.is_a?(PostAppeal) && event.succeeded?) || (event.is_a?(PostFlag) && event.rejected?)
      "approved"
    elsif (event.is_a?(PostAppeal) && event.rejected?) || (event.is_a?(PostFlag) && event.succeeded?)
      "deleted"
    else
      "pending"
    end
  end

  def is_creator_visible?(user = CurrentUser.user)
    case event
    when PostAppeal, PostApproval
      true
    when PostFlag
      flag = event
      Pundit.policy!([user, nil], flag).can_view_flagger?
    end
  end

  def attributes
    {
      "creator_id": nil,
      "created_at": nil,
      "reason": nil,
      "status": nil,
      "type": nil
    }
  end

  # XXX can't use hidden_attributes because we don't inherit from ApplicationRecord.
  def serializable_hash(**options)
    hash = super
    hash = hash.except(:creator_id) unless is_creator_visible?
    hash
  end
end
