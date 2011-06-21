class PostSetPresenter < Presenter
  attr_accessor :post_set, :tag_set_presenter
  
  def initialize(post_set)
    @post_set = post_set
    @tag_set_presenter = TagSetPresenter.new(RelatedTagCalculator.calculate_from_sample_to_array(@post_set.tag_string).map {|x| x[0]})
  end
  
  def posts
    post_set.posts
  end
  
  def tag_list_html(template)
    tag_set_presenter.tag_list_html(template)
  end
  
  def post_previews_html
    html = ""
    
    posts.each do |post|
      html << PostPresenter.preview(post)
    end
    
    html.html_safe
  end
end
