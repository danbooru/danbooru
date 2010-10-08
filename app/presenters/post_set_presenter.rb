require 'pp'

class PostSetPresenter < Presenter
  attr_accessor :post_set
  
  def initialize(post_set)
    @post_set = post_set
  end
  
  def posts
    post_set.posts
  end
  
  def tag_list_html
    ""
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
      sequential_pagination_html(template)
    else
      numbered_pagination_html(template)
    end
  end
  
  def sequential_pagination_html(template)
    html = "<menu>"
    prev_url = template.request.env["HTTP_REFERER"]
    next_url = template.posts_path(:tags => template.params[:tags], before_id => post_set.posts[-1].id, :page => nil)
    html << %{<li><a href="#{prev_url}">&laquo; Previous</a></li>}
    if post_set.posts.any?
      html << %{<li><a href="#{next_url}">Next &raquo;</a></li>}
    end
    html << "</menu>"
    html.html_safe
  end
  
  def numbered_pagination_html(template)
    total_pages = (post_set.count.to_f / post_set.limit.to_f).ceil
    current_page = [1, post_set.page].max
    html = "<menu>"
    window = 3
    if total_pages <= (window * 2) + 5
      1.upto(total_pages) do |page|
        html << numbered_pagination_item(template, page, current_page)
      end
    elsif current_page <= window + 2
      1.upto(current_page + window) do |page|
        html << numbered_pagination_item(template, page, current_page)
      end
      html << numbered_pagination_item(template, "...", current_page)
      html << numbered_pagination_item(template, total_pages, current_page)
      
    elsif current_page >= total_pages - (window + 1)
      html << numbered_pagination_item(template, 1, current_page)
      html << numbered_pagination_item(template, "...", current_page)
      (current_page - window).upto(total_pages) do |page|
        html << numbered_pagination_item(template, page, current_page)
      end
    else
      html << numbered_pagination_item(template, 1, current_page)
      html << numbered_pagination_item(template, "...", current_page)
      (current_page - window).upto(current_page + window) do |page|
        html << numbered_pagination_item(template, page, current_page)
      end
      html << numbered_pagination_item(template, "...", current_page)
      html << numbered_pagination_item(template, total_pages, current_page)
    end
    html << "</menu>"
    html.html_safe
  end
  
  def numbered_pagination_item(template, page, current_page)
    html = "<li>"
    if page == "..."
      html << "..."
    elsif page == current_page
      html << page.to_s
    else
      html << template.link_to(page, template.__send__(:posts_path, :tags => template.params[:tags], :page => page))
    end
    html << "</li>"
    html.html_safe
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
