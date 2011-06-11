module PostSets
  module Numbered
    def total_pages
      @total_pages ||= (count / limit.to_f).ceil.to_i
    end
    
    def reload
      super
      @total_pages = nil
    end
    
    def slice(relation)
      relation.offset(offset).limit(limit).all
    end
    
    def pagination_options
      {:offset => offset}
    end
    
    def is_first_page?
      offset == 0
    end
    
    def validate
      super
      validate_page
    end
    
    def validate_page
      if page > 1_000
        raise Error.new("You cannot explicitly specify the page after page 1000")
      end
    end
    
    def page
      @page ||= params[:page] ? params[:page].to_i : 1
    end
    
    def offset
      ((page < 1) ? 0 : (page - 1)) * limit
    end
  end
end
