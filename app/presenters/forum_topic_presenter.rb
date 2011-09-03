class ForumTopicPresenter < Presenter
  attr_reader :forum_topic, :forum_posts
  
  def initialize(forum_topic, forum_posts)
    @forum_posts = forum_posts
    @forum_topic = forum_topic
  end
end
