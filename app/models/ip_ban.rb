class IpBan < ActiveRecord::Base
  belongs_to :creator, :class_name => "User"
  before_validation :initialize_creator, :on => :create
  validates_presence_of :reason, :creator
  validates_uniqueness_of :ip_addr
  
  def self.is_banned?(ip_addr)
    exists?(["ip_addr = ?", ip_addr])
  end

  def self.query(user_ids)
    comments = count_by_ip_addr("comments", user_ids, "creator_id", "ip_addr")
    notes = count_by_ip_addr("note_versions", user_ids, "updater_id", "updater_ip_addr")
    pools = count_by_ip_addr("pool_versions", user_ids, "updater_id", "updater_ip_addr")
    wiki_pages = count_by_ip_addr("wiki_page_versions", user_ids, "updater_id", "updater_ip_addr")
    
    return {
      "comments" => comments,
      "notes" => notes,
      "pools" => pools,
      "wiki_pages" => wiki_pages
    }
  end
  
  def self.count_by_ip_addr(table, user_ids, user_id_field = "user_id", ip_addr_field = "ip_addr")
    select_all_sql("SELECT #{ip_addr_field}, count(*) FROM #{table} WHERE #{user_id_field} IN (?) GROUP BY #{ip_addr_field} ORDER BY count(*) DESC", user_ids)
  end
  
  def initialize_creator
    self.creator_id = CurrentUser.id
  end
end
