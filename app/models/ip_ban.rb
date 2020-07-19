class IpBan < ApplicationRecord
  belongs_to :creator, class_name: "User"

  validate :validate_ip_addr
  validates :reason, presence: true

  before_save :create_mod_action

  deletable
  enum category: {
    full: 0,
    partial: 100
  }, _suffix: "ban"

  def self.ip_matches(ip_addr)
    where("ip_addr >>= ?", ip_addr)
  end

  def self.hit!(category, ip_addr)
    ip_ban = active.where(category: category).ip_matches(ip_addr).first
    return false unless ip_ban

    IpBan.increment_counter(:hit_count, ip_ban.id, touch: [:last_hit_at])
    true
  end

  def self.search(params)
    q = super
    q = q.search_attributes(params, :reason)
    q = q.text_attribute_matches(:reason, params[:reason_matches])

    if params[:ip_addr].present?
      q = q.where("ip_addr = ?", params[:ip_addr])
    end

    q.apply_default_order(params)
  end

  def create_mod_action
    if new_record?
      ModAction.log("#{creator.name} created ip ban for #{ip_addr}", :ip_ban_create)
    elsif is_deleted? == true && is_deleted_was == false
      ModAction.log("#{CurrentUser.user.name} deleted ip ban for #{ip_addr}", :ip_ban_delete)
    elsif is_deleted? == false && is_deleted_was == true
      ModAction.log("#{CurrentUser.user.name} undeleted ip ban for #{ip_addr}", :ip_ban_undelete)
    end
  end

  def validate_ip_addr
    if ip_addr.blank?
      errors[:ip_addr] << "is invalid"
    elsif ip_addr.private? || ip_addr.loopback? || ip_addr.link_local?
      errors[:ip_addr] << "must be a public address"
    elsif full_ban? && ip_addr.ipv4? && ip_addr.prefix < 24
      errors[:ip_addr] << "may not have a subnet bigger than /24"
    elsif partial_ban? && ip_addr.ipv4? && ip_addr.prefix < 8
      errors[:ip_addr] << "may not have a subnet bigger than /8"
    elsif full_ban? && ip_addr.ipv6? && ip_addr.prefix < 64
      errors[:ip_addr] << "may not have a subnet bigger than /64"
    elsif partial_ban? && ip_addr.ipv6? && ip_addr.prefix < 20
      errors[:ip_addr] << "may not have a subnet bigger than /20"
    elsif new_record? && IpBan.active.ip_matches(subnetted_ip).exists?
      errors[:ip_addr] << "is already banned"
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

  def ip_addr=(ip_addr)
    super(ip_addr.strip)
  end

  def self.searchable_includes
    [:creator]
  end

  def self.available_includes
    [:creator]
  end
end
