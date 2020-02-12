class IpBan < ApplicationRecord
  belongs_to :creator, class_name: "User"
  validate :validate_ip_addr
  validates_presence_of :reason
  validates_uniqueness_of :ip_addr
  after_create  { ModAction.log("#{creator.name} created ip ban for #{ip_addr}", :ip_ban_create) }
  after_destroy { ModAction.log("#{creator.name} deleted ip ban for #{ip_addr}", :ip_ban_delete) }

  def self.is_banned?(ip_addr)
    where("ip_addr >>= ?", ip_addr).exists?
  end

  def self.search(params)
    q = super
    q = q.search_attributes(params, :creator, :reason)

    if params[:ip_addr].present?
      q = q.where("ip_addr = ?", params[:ip_addr])
    end

    q.apply_default_order(params)
  end

  def validate_ip_addr
    if ip_addr.blank?
      errors[:ip_addr] << "is invalid"
    elsif ip_addr.ipv4? && ip_addr.prefix < 24
      errors[:ip_addr] << "may not have a subnet bigger than /24"
    elsif ip_addr.ipv6? && ip_addr.prefix < 64
      errors[:ip_addr] << "may not have a subnet bigger than /64"
    elsif ip_addr.private? || ip_addr.loopback? || ip_addr.link_local?
      errors[:ip_addr] << "must be a public address"
    end
  end

  def has_subnet?
    (ip_addr.ipv4? && ip_addr.prefix < 32) || (ip_addr.ipv6? && ip_addr.prefix < 128)
  end

  def subnetted_ip
    str = ip_addr.to_s
    str += "/" + ip_addr.prefix.to_s if has_subnet?
    str
  end

  def self.available_includes
    [:creator]
  end
end
