module Moderator
  class IpAddrSearch
    attr_reader :params, :errors

    def initialize(params)
      @params = params
      @errors = []
    end

    def execute
      if params[:user_id].present?
        search_by_user_id(params[:user_id].split(/,/).map(&:strip))
      elsif params[:user_name].present?
        search_by_user_name(params[:user_name].split(/,/).map(&:strip))
      elsif params[:ip_addr].present?
        search_by_ip_addr(params[:ip_addr].split(/,/).map(&:strip))
      else
        []
      end
    end

    def find_common_users
      user = User.find_by_name(params[:user_name])
      ip_addrs = Set.new
      user_ids = {}

      ip_addrs.merge(find_distinct_ip_addrs("comments", "ip_addr", "creator_id", user.id))
      ip_addrs.merge(find_distinct_ip_addrs("post_versions", "updater_ip_addr", "updater_id", user.id))
      ip_addrs.merge(find_distinct_ip_addrs("note_versions", "updater_ip_addr", "updater_id", user.id))
      ip_addrs.merge(find_distinct_ip_addrs("pool_versions", "updater_ip_addr", "updater_id", user.id))
      ip_addrs.merge(find_distinct_ip_addrs("wiki_page_versions", "updater_ip_addr", "updater_id", user.id))
      ip_addrs.merge(find_distinct_ip_addrs("dmails", "creator_ip_addr", "from_id", user.id))

      ip_addrs.each do |ip_addr|
        find_distinct_user_ids(user_ids, "comments", "ip_addr", "creator_id", ip_addrs.to_a)
        find_distinct_user_ids(user_ids, "post_versions", "updater_ip_addr", "updater_id", ip_addrs.to_a)
        find_distinct_user_ids(user_ids, "note_versions", "updater_ip_addr", "updater_id", ip_addrs.to_a)
        find_distinct_user_ids(user_ids, "pool_versions", "updater_ip_addr", "updater_id", ip_addrs.to_a)
        find_distinct_user_ids(user_ids, "wiki_page_versions", "updater_ip_addr", "updater_id", ip_addrs.to_a)
        find_distinct_user_ids(user_ids, "dmails", "creator_ip_addr", "from_id", ip_addrs.to_a)
      end

      user_ids
    end

  private
    def select_all_sql(sql, *params)
      ActiveRecord::Base.select_all_sql(sql, *params)
    end

    def find_distinct_ip_addrs(table_name, ip_field_name, user_field_name, user_id)
      select_all_sql("select #{ip_field_name} from #{table_name} where updated_at >= ? and #{user_field_name} = ? group by #{ip_field_name}", 3.months.ago, user_id).rows.flatten
    end

    def find_distinct_user_ids(user_ids, table_name, ip_field_name, user_field_name, ip_addrs)
      select_all_sql("select #{user_field_name}, count(*) from #{table_name} where updated_at >= ? and #{ip_field_name} in (?) group by #{user_field_name}", 3.months.ago, ip_addrs).rows.each do |user_id, count|
        user_ids[user_id] ||= 0
        user_ids[user_id] += count.to_i
      end
    end

    def search_by_ip_addr(ip_addrs)
      sums = Hash.new {|h, k| h[k] = 0}

      add_row(sums, "select creator_id as k, count(*) from comments where ip_addr in (?) group by k", ip_addrs)
      add_row(sums, "select updater_id as k, count(*) from post_versions where updater_ip_addr in (?) group by k", ip_addrs)
      add_row(sums, "select updater_id as k, count(*) from note_versions where updater_ip_addr in (?) group by k", ip_addrs)
      add_row(sums, "select updater_id as k, count(*) from pool_versions where updater_ip_addr in (?) group by k", ip_addrs)
      add_row(sums, "select updater_id as k, count(*) from wiki_page_versions where updater_ip_addr in (?) group by k", ip_addrs)
      add_row(sums, "select from_id as k, count(*) from dmails where creator_ip_addr in (?) group by k", ip_addrs)

      sums
    end

    def search_by_user_name(user_names)
      users = User.where("name in (?)", user_names)
      search_by_user_id(users.map(&:id))
    end

    def search_by_user_id(user_ids)
      sums = Hash.new {|h, k| h[k] = 0}

      add_row(sums, "select ip_addr as k, count(*) from comments where creator_id in (?) group by k", user_ids)
      add_row(sums, "select updater_ip_addr as k, count(*) from post_versions where updater_id in (?) group by k", user_ids)
      add_row(sums, "select updater_ip_addr as k, count(*) from note_versions where updater_id in (?) group by k", user_ids)
      add_row(sums, "select updater_ip_addr as k, count(*) from pool_versions where updater_id in (?) group by k", user_ids)
      add_row(sums, "select updater_ip_addr as k, count(*) from wiki_page_versions where updater_id in (?) group by k", user_ids)
      add_row(sums, "select creator_ip_addr as k, count(*) from dmails where from_id in (?) group by k", user_ids)

      sums
    end

    def add_row(sums, sql, ip_addrs)
      select_all_sql(sql, ip_addrs).each do |row|
        sums[row["k"]] += row["count"].to_i
      end
    end
  end
end
