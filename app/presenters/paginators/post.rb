module Paginators
  class Post < Base
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
      
      def sequential_link(template)
        template.posts_path(:tags => template.params[:tags], before_id => post_set.posts[-1].id, :page => nil)
      end
    
      def paginated_link(template, page)
        template.link_to(page, template.posts_path(:tags => template.params[:tags], :page => page))
      end
  end
end
