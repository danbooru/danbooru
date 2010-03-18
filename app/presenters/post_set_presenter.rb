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
  
  def wiki_html
    ""
  end
  
  def pagination_html(template)
    if @post_set.use_sequential_paginator?
      sequential_pagination_html(template)
    else
      numbered_pagination_html(template)
    end
  end
  
  def sequential_pagination_html(template)
    html = "<menu>"
    prev_url = template.request.env["HTTP_REFERER"]
    next_url = template.posts_path(:tags => template.params[:tags], before_id => @post_set.posts[-1].id, :page => nil)
    html << %{<li><a href="#{prev_url}">&laquo; Previous</a></li>}
    if @post_set.posts.any?
      html << %{<li><a href="#{next_url}">Next &raquo;</a></li>}
    end
    html << "</menu>"
    html.html_safe
  end
  
  def numbered_pagination_html(template)
    total_pages = (@post_set.count.to_f / @post_set.limit.to_f).ceil
    current_page = [1, @post_set.page].max
    before_current_page = current_page - 1
    after_current_page = current_page + 1
    html = "<menu>"

    current_page_min = [1, current_page - 2].max
    current_page_max = [total_pages, current_page + 2].min
    
    if current_page == 1
      # do nothing
    elsif current_page_min == 1
      1.upto(before_current_page) do |i|
        html << numbered_pagination_item(template, i)
      end
    else
      1.upto(3) do |i|
        html << numbered_pagination_item(template, i)
      end
      
      html << "<li>...</li>"
      
      current_page_min.upto(before_current_page) do |i|
        html << numbered_pagination_item(template, i)
      end
    end
    
    html << %{<li class="current-page">#{current_page}</li>}
    
    if current_page == total_pages
      # do nothing
    elsif current_page_max == total_pages
      after_current_page.upto(total_pages) do |i|
        html << numbered_pagination_item(template, i)
      end
    else
      after_current_page.upto(after_current_page + 2) do |i|
        html << numbered_pagination_item(template, i)
      end
      
      if total_pages > 5
        html << "<li>...</li>"
      
        (after_current_page + 3).upto(total_pages) do |i|
          html << numbered_pagination_item(template, i)
        end
      end
    end
    
    html << "</menu>"
    html.html_safe
  end
  
  def numbered_pagination_item(template, page)
    html = "<li>"
    html << template.link_to(page, template.__send__(:posts_path, :tags => template.params[:tags], :page => page))
    html << "</li>"
    html.html_safe
  end
  
  def post_previews_html
    html = ""
    
    posts.each do |post|
      flags = []
      flags << "pending" if post.is_pending?
      flags << "flagged" if post.is_flagged?
      flags << "deleted" if post.is_deleted?
      
      html << %{<article id="post_#{post.id}" data-id="#{post.id}" data-tags="#{h(post.tag_string)}" data-uploader="#{h(post.uploader_name)}" data-rating="#{post.rating}" data-width="#{post.image_width}" data-height="#{post.image_height}" data-flags="#{flags.join(' ')}">}
      html << %{<a href="/posts/#{post.id}">}
      html << %{<img src="#{post.preview_file_url}">}
      html << %{</a>}
      html << %{</article>}
    end
    
    html.html_safe
  end
end
