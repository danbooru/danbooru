class ForumTopicPresenter < Presenter
  attr_reader :forum_topic, :forum_posts
  
  def initialize(forum_topic, forum_posts)
    @forum_posts = forum_posts
    @forum_topic = forum_topic
  end
  
  def pagination_html(template)
    Paginators::ForumTopic.new(forum_topic, forum_posts).numbered_pagination_html(template)
  end
end
