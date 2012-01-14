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
    Array(@tags).each do |tag|
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
    
    unless options[:name_only]
      if categories[tag] == 1
        html << %{<a class="wiki-link" href="/artists/show_or_new?name=#{u(tag)}">?</a> }
      else
        html << %{<a class="wiki-link" href="/wiki_pages?title=#{u(tag)}">?</a> }
      end

      if CurrentUser.user.is_privileged?
        html << %{<a href="/posts?tags=#{u(current_query)}+#{u(tag)}" class="search-inc-tag">+</a> }
        html << %{<a href="/posts?tags=#{u(current_query)}+-#{u(tag)}" class="search-exl-tag">&ndash;</a> }
      end
    end
    
    humanized_tag = tag.tr("_", " ")
    path = options[:path_prefix] || "/posts"
    html << %{<a class="search-tag" href="#{path}?tags=#{u(tag)}">#{h(humanized_tag)}</a> }
    
    unless options[:name_only]
      if counts[tag].to_i > 1_000
        post_count = "#{counts[tag].to_i / 1_000}k"
      else
        post_count = counts[tag].to_s
      end
      
      html << %{<span class="post-count">#{post_count}</span>}
    end
    
    html << "</li>"
    html
  end
end
