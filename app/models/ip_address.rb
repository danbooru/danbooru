class IpAddress < ApplicationRecord
  belongs_to :model, polymorphic: true
  belongs_to :user
  attribute :ip_addr, IpAddressType.new

  def self.model_types
    %w[Post User Comment Dmail ArtistVersion ArtistCommentaryVersion NoteVersion WikiPageVersion]
  end

  def self.visible(user)
    user.is_admin? ? all : where.not(model_type: "Dmail")
  end

  def self.search(params)
    q = super
    q = q.search_attributes(params, :ip_addr)
    q.order(created_at: :desc)
  end

  def self.group_by_ip_addr(ipv4_masklen = nil, ipv6_masklen = nil)
    ipv4_masklen ||= 32
    ipv6_masklen ||= 128

    q = select(sanitize_sql([<<~SQL, ipv4_masklen, ipv6_masklen]))
      CASE
        WHEN family(ip_addr) = 4
        THEN network(set_masklen(ip_addr, ?))
        ELSE network(set_masklen(ip_addr, ?))
      END AS ip_addr,
      COUNT(*) AS count_all
    SQL

    q.group("1").reorder("count_all DESC, ip_addr")
  end

  def self.group_by_user
    group(:user_id).select("user_id, COUNT(*) AS count_all").reorder("count_all DESC, user_id")
  end

  def lookup
    @lookup ||= IpLookup.new(ip_addr)
  end

  def to_s
    # include the subnet mask only when the IP denotes a subnet.
    (ip_addr.size > 1) ? ip_addr.to_string : ip_addr.to_s
  end

  def readonly?
    true
  end

  def self.searchable_includes
    [:user, :model]
  end

  def self.available_includes
    [:user, :model]
  end
end
