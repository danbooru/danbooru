class IpAddress < ApplicationRecord
  belongs_to :model, polymorphic: true
  belongs_to :user
  attribute :ip_addr, IpAddressType.new

  def self.model_types
    %w[Post User Comment Dmail ArtistVersion ArtistCommentaryVersion NoteVersion WikiPageVersion]
  end

  def self.search(params)
    q = super
    q = q.where.not(model_type: "Dmail") unless CurrentUser.is_admin?
    q = q.search_attributes(params, :user, :model_type, :model_id, :ip_addr)
    q.order(created_at: :desc)
  end

  def self.group_by_ip_addr
    group(:ip_addr).select("ip_addr, COUNT(*) AS count_all").reorder("count_all DESC, ip_addr")
  end

  def self.group_by_user
    group(:user_id).select("user_id, COUNT(*) AS count_all").reorder("count_all DESC, user_id")
  end

  def readonly?
    true
  end
end
