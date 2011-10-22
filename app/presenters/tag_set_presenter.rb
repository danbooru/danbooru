=begin rdoc
  A tag set represents a set of tags that are displayed together.
  This class makes it easy to fetch the categories for all the 
  tags in one call instead of fetching them sequentially.
=end

class TagSetPresenter < Presenter
  def initialize(tags)
    @tags = tags
  end
  
  def tag_list_html(template, options = {})
    html = ""
    html << "<ul>"
    @tags.each do |tag|
      html << build_list_item(tag, template, options)
    end
    html << "</ul>"
    html.html_safe
  end

private
  def categories
    @categories ||= Tag.categories_for(@tags)
  end
  
  def counts
    @counts ||= Tag.counts_for(@tags).inject({}) do |hash, x|
      hash[x["name"]] = x["post_count"]
      hash
    end
  end
  
  def build_list_item(tag, template, options)
    html = ""
    html << %{<li class="category-#{categories[tag]}">}
    current_query = template.params[:tags] || ""
    
    if CurrentUser.user.is_privileged?
      if categories[tag] == 1
        html << %{<a href="/artists/show_or_new?name=#{u(tag)}">?</a> }
      else
        html << %{<a href="/wiki_pages?title=#{u(tag)}">?</a> }
      end
      html << %{<a href="/posts?tags=#{u(current_query)}+#{u(tag)}" class="search-inc-tag">+</a> }
      html << %{<a href="/posts?tags=#{u(current_query)}+-#{u(tag)}" class="search-exl-tag">&ndash;</a> }
    end
    
    humanized_tag = tag.tr("_", " ")
    html << %{<a href="/posts?tags=#{u(tag)}">#{h(humanized_tag)}</a> }
    html << %{<span class="post-count">} + counts[tag].to_s + %{</span>}
    
    html << "</li>"
    html
  end
end
