require 'pp'

class PostSetPresenter < Presenter
  attr_accessor :post_set, :tag_set_presenter
  
  def initialize(post_set)
    @post_set = post_set
    @tag_set_presenter = TagSetPresenter.new(RelatedTagCalculator.calculate_from_sample_to_array(@post_set.tags).map {|x| x[0]})
  end
  
  def posts
    post_set.posts
  end
  
  def tag_list_html(template)
    tag_set_presenter.tag_list_html(template)
  end
  
  def wiki_html(template)
    if post_set.has_wiki?
      wiki_page = WikiPage.find_by_title(post_set.tags)
      html = '<section>'
      if wiki_page.nil?
        html << '<p>'
        html << 'There is no wiki for this tag.'
        html << ' '
        html << template.link_to("Create a new page", template.new_wiki_page_path(:title => post_set.tags))
        html << '.'
        html << '</p>'
      else
        html << '<h2>'
        html << template.h(wiki_page.title)
        html << '</h2>'
        html << template.format_text(wiki_page.body)
      end
      html << '</section>'
      html.html_safe
    end
  end
  
  def post_previews_html
    html = ""
    
    posts.each do |post|
      html << PostPresenter.preview(post)
    end
    
    html.html_safe
  end
end
