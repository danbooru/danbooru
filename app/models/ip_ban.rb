class IpBan < ApplicationRecord
  IP_ADDR_REGEX = /\A(?:[0-9]{1,3}\.){3}[0-9]{1,3}\Z/
  belongs_to_creator
  validates_presence_of :reason, :creator, :ip_addr
  validates_format_of :ip_addr, :with => IP_ADDR_REGEX
  validates_uniqueness_of :ip_addr, :if => lambda {|rec| rec.ip_addr =~ IP_ADDR_REGEX}
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

  def self.query(user_ids)
    comments = count_by_ip_addr("comments", user_ids, "creator_id", "ip_addr")
    notes = count_by_ip_addr("note_versions", user_ids, "updater_id", "updater_ip_addr")
#    pools = count_by_ip_addr("pool_versions", user_ids, "updater_id", "updater_ip_addr")
    wiki_pages = count_by_ip_addr("wiki_page_versions", user_ids, "updater_id", "updater_ip_addr")

    return {
      "comments" => comments,
      "notes" => notes,
#      "pools" => pools,
      "wiki_pages" => wiki_pages
    }
  end

  def self.count_by_ip_addr(table, user_ids, user_id_field = "user_id", ip_addr_field = "ip_addr")
    select_all_sql("SELECT #{ip_addr_field}, count(*) FROM #{table} WHERE #{user_id_field} IN (?) GROUP BY #{ip_addr_field} ORDER BY count(*) DESC", user_ids).to_hash
  end
end
