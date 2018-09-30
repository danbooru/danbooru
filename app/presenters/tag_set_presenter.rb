=begin rdoc
  A tag set represents a set of tags that are displayed together.
  This class makes it easy to fetch the categories for all the
  tags in one call instead of fetching them sequentially.
=end

class TagSetPresenter < Presenter
  extend Memoist
  attr_reader :tag_names

  def initialize(tag_names)
    @tag_names = tag_names
  end

  def tag_list_html(current_query: "", show_extra_links: false, name_only: false)
    html = ""

    if ordered_tags.present?
      html << '<ul itemscope itemtype="http://schema.org/ImageObject">'
      ordered_tags.each do |tag|
        html << build_list_item(tag, current_query: current_query, show_extra_links: show_extra_links, name_only: name_only)
      end
      html << "</ul>"
    end

    html.html_safe
  end

  def split_tag_list_html(headers: true, category_list: TagCategory.split_header_list, current_query: "", show_extra_links: false, name_only: false, humanize_tags: true)
    html = ""

    category_list.each do |category|
      typetags = ordered_tags.select { |tag| tag.category == Tag.categories.value_for(category) }

      if typetags.any?
        html << TagCategory.header_mapping[category] if headers
        html << %{<ul class="#{category}-tag-list">}
        typetags.each do |tag|
          html << build_list_item(tag, current_query: current_query, show_extra_links: show_extra_links, name_only: name_only, humanize_tags: humanize_tags)
        end
        html << "</ul>"
      end
    end

    html.html_safe
  end

  # compact (horizontal) list, as seen in the /comments index.
  def inline_tag_list_html(humanize_tags: true)
    html = split_tag_list_html(category_list: TagCategory.categorized_list, headers: false, show_extra_links: false, name_only: true, humanize_tags: humanize_tags)
    %{<span class="inline-tag-list">#{html}</span>}.html_safe
  end

  private

  def tags
    Tag.where(name: tag_names).select(:name, :post_count, :category)
  end
  memoize :tags

  def ordered_tags
    names_to_tags = tags.map { |tag| [tag.name, tag] }.to_h

    tag_names.map do |name|
      names_to_tags[name] || Tag.new(name: name).freeze
    end
  end
  memoize :ordered_tags

  def build_list_item(tag, name_only: false, humanize_tags: true, show_extra_links: false, current_query: "")
    name = tag.name
    count = tag.post_count
    category = tag.category

    html = %{<li class="category-#{tag.category}">}

    unless name_only
      if category == Tag.categories.artist
        html << %{<a class="wiki-link" href="/artists/show_or_new?name=#{u(name)}">?</a> }
      else
        html << %{<a class="wiki-link" href="/wiki_pages/show_or_new?title=#{u(name)}">?</a> }
      end

      if show_extra_links && current_query.present?
        html << %{<a rel="nofollow" href="/posts?tags=#{u(current_query)}+#{u(name)}" class="search-inc-tag">+</a> }
        html << %{<a rel="nofollow" href="/posts?tags=#{u(current_query)}+-#{u(name)}" class="search-exl-tag">&ndash;</a> }
      end
    end

    humanized_tag = humanize_tags ? name.tr("_", " ") : name
    itemprop = 'itemprop="author"' if category == Tag.categories.artist
    html << %{<a class="search-tag" #{itemprop} href="/posts?tags=#{u(name)}">#{h(humanized_tag)}</a> }

    unless name_only || tag.new_record?
      if count >= 10_000
        post_count = "#{count / 1_000}k"
      elsif count >= 1_000
        post_count = "%.1fk" % (count / 1_000.0)
      else
        post_count = count
      end

      is_underused_tag = count <= 1 && category == Tag.categories.general
      klass = "post-count#{is_underused_tag ? " low-post-count" : ""}"
      title = "New general tag detected. Check the spelling or populate it now."

      html << %{<span class="#{klass}"#{is_underused_tag ? " title='#{title}'" : ""}>#{post_count}</span>}
    end

    html << "</li>"
    html
  end
end
