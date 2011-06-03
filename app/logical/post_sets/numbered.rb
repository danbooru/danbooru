module PostSets
  module Numbered
    attr_reader :page
    
    def initialize(params)
      super
      @page = options[:page] ? options[:page].to_i : 1
    end

    def total_pages
      @total_pages ||= (count / limit.to_f).ceil.to_i
    end
    
    def reload
      super
      @total_pages = nil
    end
    
    def slice(relation)
      relation.offset(offset).all
    end
    
    def pagination_options
      {:offset => offset}
    end
    
    def is_first_page?
      offset == 0
    end
    
    def offset
      ((page < 1) ? 0 : (page - 1)) * limit
    end
  end
end
