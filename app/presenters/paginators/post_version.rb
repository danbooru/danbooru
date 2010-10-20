module Paginators
  class PostVersion < Base
    attr_accessor :post_set
    
    def initialize(post_set)
      @post_set = post_set
    end
    
    def numbered_pagination_html(template)
      raise NotImplementedError
    end
    
    protected
      def sequential_link(template)
        template.post_versions_path(:before_time => post_set.posts[-1].last_commented_at, :page => nil)
      end
  end
end
