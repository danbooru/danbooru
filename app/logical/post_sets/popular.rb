module PostSets
  class Popular < Base
    attr_reader :date, :scale
    
    def initialize(date, scale)
      @date = date.blank? ? Time.zone.now : Time.zone.parse(date)
      @scale = scale
    end
    
    def posts
      ::Post.where("created_at between ? and ?", min_date.beginning_of_day, max_date.end_of_day).order("score desc").limit(limit)
    end
    
    def limit
      25
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
