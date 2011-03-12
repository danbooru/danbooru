module Paginators
  class ForumPost < Base
    attr_accessor :forum_posts
    
    def initialize(forum_posts)
      @forum_posts = forum_posts
    end
    
    protected
      def total_pages
        forum_posts.total_entries
      end
      
      def current_page
        forum_posts.current_page
      end
      
      def paginated_link(template, page)
        template.link_to(page, template.forum_posts_path(:search => template.params[:search], :page => page))
      end
  end
end
