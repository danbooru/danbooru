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
    if post_set.is_single_tag?
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
  
  def pagination_html(template)
    if post_set.use_sequential_paginator?
      Paginators::Post.new(post_set).sequential_pagination_html(template)
    else
      Paginators::Post.new(post_set).numbered_pagination_html(template)
    end
  end
  
  def post_previews_html
    html = ""
    
    posts.each do |post|
      flags = []
      flags << "pending" if post.is_pending?
      flags << "flagged" if post.is_flagged?
      flags << "removed" if post.is_removed?
      
      html << %{<article id="post_#{post.id}" data-id="#{post.id}" data-tags="#{h(post.tag_string)}" data-uploader="#{h(post.uploader_name)}" data-rating="#{post.rating}" data-width="#{post.image_width}" data-height="#{post.image_height}" data-flags="#{flags.join(' ')}">}
      html << %{<a href="/posts/#{post.id}">}
      html << %{<img src="#{post.preview_file_url}">}
      html << %{</a>}
      html << %{</article>}
    end
    
    html.html_safe
  end
end
