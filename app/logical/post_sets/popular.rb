module PostSets
  class Popular < PostSets::Base
    attr_reader :date, :scale, :limit

    def initialize(date, scale, limit: nil)
      @date = date.blank? ? Time.zone.now : Time.zone.parse(date)
      @scale = scale
      @limit = limit || CurrentUser.per_page
    end

    def posts
      @posts ||= begin
        query = ::Post.where("created_at between ? and ?", min_date.beginning_of_day, max_date.end_of_day).order("score desc").limit(limit)
        query.each # hack to force rails to eager load
        query
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

    def presenter
      ::PostSetPresenters::Popular.new(self)
    end
  end
end
