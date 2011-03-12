module Paginators
  class ForumTopic < Base
    attr_accessor :forum_topic, :forum_posts
    
    def initialize(forum_topic, forum_posts)
      @forum_topic = forum_topic
      @forum_posts = forum_posts
    end
    
    protected
      def total_pages
        forum_posts.total_pages
      end
      
      def current_page
        forum_posts.current_page
      end
      
      def paginated_link(template, page)
        template.link_to(page, template.forum_topic_path(forum_topic, :page => page))
      end
  end
end
