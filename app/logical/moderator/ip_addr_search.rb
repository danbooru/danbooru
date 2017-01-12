module Moderator
  class IpAddrSearch
    attr_reader :params

    def initialize(params)
      @params = params
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

  private
    def search_by_ip_addr(ip_addrs)
      sums = Hash.new {|h, k| h[k] = 0}

      add_row(sums, NoteVersion.where(updater_ip_addr: ip_addrs).group(:updater).count)
      add_row(sums, PoolArchive.where(updater_ip_addr: ip_addrs).group(:updater).count) if PoolArchive.enabled?
      add_row(sums, PostVersion.where(updater_ip_addr: ip_addrs).group(:updater).count)
      add_row(sums, WikiPageVersion.where(updater_ip_addr: ip_addrs).group(:updater).count)
      add_row(sums, Comment.where(ip_addr: ip_addrs).group(:creator).count)
      add_row(sums, Dmail.where(creator_ip_addr: ip_addrs).group(:from).count)
      add_row(sums, Hash[User.where(last_ip_addr: ip_addrs).collect { |user| [user, 1] }])

      sums
    end

    def search_by_user_name(user_names)
      user_ids = user_names.map { |name| User.name_to_id(name) }
      search_by_user_id(user_ids)
    end

    def search_by_user_id(user_ids)
      sums = Hash.new {|h, k| h[k] = 0}
      users = User.find(user_ids)

      add_row(sums, NoteVersion.where(updater: users).group(:updater_ip_addr).count)
      add_row(sums, PoolArchive.where(updater: users).group(:updater_ip_addr).count) if PoolArchive.enabled?
      add_row(sums, PostVersion.where(updater: users).group(:updater_ip_addr).count)
      add_row(sums, WikiPageVersion.where(updater: users).group(:updater_ip_addr).count)
      add_row(sums, Comment.where(creator: users).group(:ip_addr).count)
      add_row(sums, Dmail.where(from: users).group(:creator_ip_addr).count)

      sums
    end

    def add_row(sums, counts)
      sums.merge!(counts) { |key, oldcount, newcount| oldcount + newcount }
    end
  end
end
