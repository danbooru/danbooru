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
  
  def build_list_item(tag, template, options)
    html = ""
    html << %{<li data-tag-type="#{categories[tag]}" data-tag-name="#{u(tag)}">}
    
    if CurrentUser.user.is_privileged?
      html << %{<a href="/wiki_pages?title=#{u(tag)}">?</a> }
      html << %{<a href="#" class="search-inc-tag">+</a> }
      html << %{<a href="#" class="search-exl-tag">&ndash;</a> }
    end
    
    humanized_tag = tag.tr("_", " ")
    html << %{<a href="/posts?tags=#{u(tag)}">#{h(humanized_tag)}</a>}
    html << "</li>"
    html
  end
end
