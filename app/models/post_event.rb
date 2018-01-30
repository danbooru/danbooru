class PostEvent
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  include ActiveModel::Serializers::Xml

  attr_accessor :event
  delegate :id, :creator, :creator_id, :reason, :is_resolved, :created_at, to: :event

  def self.find_for_post(post_id)
    post = Post.find(post_id)
    (post.appeals + post.flags).sort_by(&:created_at).reverse.map { |e| new(event: e) }
  end

  def type_name
    case event
    when PostFlag
      "flag"
    when PostAppeal
      "appeal"
    end
  end

  def type
    type_name.first
  end

  def is_creator_visible?(user = CurrentUser.user)
    case event
    when PostAppeal
      true
    when PostFlag
      flag = event
      user.can_view_flagger_on_post?(flag)
    end
  end

  def attributes
    {
      "creator_id": nil,
      "created_at": nil,
      "reason": nil,
      "is_resolved": nil,
      "type": nil,
      "id": nil,
    }
  end
end
