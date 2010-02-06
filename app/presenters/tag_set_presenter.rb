=begin rdoc
  A tag set represents a set of tags that are displayed together.
  This class makes it easy to fetch the categories for all the 
  tags in one call instead of fetching them sequentially.
=end

class TagSetPresenter < Presenter
  def initialize(source)
    @category_cache = {}
  end
  
  def to_list_html(template, options = {})
    ul_class_attribute = options[:ul_class] ? %{class="#{options[:ul_class]}"} : ""
    ul_id_attribute = options[:ul_id] ? %{id="#{options[:ul_id]}"} : ""

    html = ""
    html << "<ul #{ul_class_attribute} #{ul_id_attribute}>"
    @tags.each do |tag|
      html << build_list_item(tag, template, options)
    end
    html << "</ul>"
    html
  end

private
  def fetch_categories(tags)
  end
  
  def build_list_item(tag, template, options)
    html = ""
    html << "<li>"
    
    if options[:show_extra_links]
    end
    
    humanized_tag = tag.tr("_", " ")
    html << %{a href="/posts?tags=#{u(tag)}">#{h(humanized_tag)}</a>}
    html << "</li>"
    html
  end
end
