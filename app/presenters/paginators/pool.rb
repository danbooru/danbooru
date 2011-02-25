module Paginators
  class Pool < Base
    attr_accessor :post_set
    
    def initialize(post_set)
      @post_set = post_set
    end
    
    protected
      def total_pages
        (post_set.count.to_f / post_set.limit.to_f).ceil
      end
      
      def current_page
        [1, post_set.page].max
      end
      
      def paginated_link(template, page)
        template.link_to(page, template.pool_path(post_set.pool, :page => page))
      end
  end
end
