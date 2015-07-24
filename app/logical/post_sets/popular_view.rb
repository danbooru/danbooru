module PostSets
  class PopularView < PostSets::Base
    attr_reader :date, :scale

    def initialize(date, scale)
      @date = date.blank? ? Time.zone.now : Time.zone.parse(date)
      @scale = scale || "Day"
    end

    def posts
      @posts ||= begin
        array = fetch_data.scan(/\S+/).in_groups_of(2)
        post_ids = array.map(&:first)
        posts = ::Post.where(id: post_ids).order(arbitrary_sql_order_clause(post_ids, "posts"))
        posts.each.with_index do |post, i|
          post.view_count = array[i][1].to_i
        end
        posts
      end
    end

    def min_date
      case scale
      when "week"
        date.beginning_of_week

      when "month"
        date.beginning_of_month

      else
        date
      end
    end

    def max_date
      case scale
      when "week"
        date.end_of_week

      when "month"
        date.end_of_month

      else
        date
      end
    end

    def source
      "popular_by_#{scale.downcase}"
    end

    def fetch_data
      dates = date.strftime('%Y-%m-%d')
      Cache.get("pv-#{scale}-#{dates}", 1.minute) do
        url = URI.parse("#{Danbooru.config.report_server}/hits/#{source}?date=#{dates}")
        response = []
        Net::HTTP.start(url.host, url.port, :use_ssl => url.is_a?(URI::HTTPS)) do |http|
          http.read_timeout = 1
          http.request_get(url.request_uri) do |res|
            if res.is_a?(Net::HTTPSuccess)
              response = res.body
            end
          end
        end
        response
      end
    end

    def presenter
      ::PostSetPresenters::Popular.new(self)
    end
  end
end
