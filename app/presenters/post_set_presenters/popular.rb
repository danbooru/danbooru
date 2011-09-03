module PostSetPresenters
  class Popular < Base
    attr_accessor :post_set, :tag_set_presenter
    delegate :posts, :date, :min_date, :max_date, :to => :post_set
    
    def initialize(post_set)
      @post_set = post_set
    end

    def prev_day
      date - 1
    end
    
    def next_day
      date + 1
    end
    
    def prev_week
      date - 7
    end
    
    def next_week
      date + 7
    end
    
    def prev_month
      1.month.ago(date)
    end
    
    def next_month
      1.month.since(date)
    end
    
    def range_text
      if min_date == max_date
        date.strftime("%B %d, %Y")
      elsif max_date - min_date == 6
        min_date.strftime("Week of %B %d, %Y")
      else
        date.strftime("%B %Y")
      end
    end
  end
end
