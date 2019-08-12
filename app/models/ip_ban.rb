class IpBan < ApplicationRecord
  IP_ADDR_REGEX = /\A(?:[0-9]{1,3}\.){3}[0-9]{1,3}\Z/
  belongs_to_creator
  validates_presence_of :reason, :ip_addr
  validates_format_of :ip_addr, :with => IP_ADDR_REGEX
  validates_uniqueness_of :ip_addr, :if => ->(rec) {rec.ip_addr =~ IP_ADDR_REGEX}
  after_create do |rec|
    ModAction.log("#{CurrentUser.name} created ip ban for #{rec.ip_addr}",:ip_ban_create)
  end
  after_destroy do |rec|
    ModAction.log("#{CurrentUser.name} deleted ip ban for #{rec.ip_addr}",:ip_ban_delete)
  end

  def self.is_banned?(ip_addr)
    exists?(["ip_addr = ?", ip_addr])
  end

  def self.search(params)
    q = super

    if params[:ip_addr].present?
      q = q.where("ip_addr = ?", params[:ip_addr])
    end

    q.apply_default_order(params)
  end
end
