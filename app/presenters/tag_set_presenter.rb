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
    if @tags.present?
      html << '<ul itemscope itemtype="http://schema.org/ImageObject">'
      @tags.each do |tag|
        html << build_list_item(tag, template, options)
      end
      html << "</ul>"
    end

    html.html_safe
  end

  def split_tag_list_html(template, category_list: TagCategory.split_header_list, headers: true, **options)
    html = ""

    category_list.each do |category|
      typetags = typed_tags(category)
      if typetags.any?
        html << TagCategory.header_mapping[category] if headers
        html << %{<ul class="#{category}-tag-list">}
        typetags.each do |tag|
          html << build_list_item(tag, template, **options)
        end
        html << "</ul>"
      end
    end

    html.html_safe
  end

  # compact (horizontal) list, as seen in the /comments index.
  def inline_tag_list_html(template, classes: "inline-tag-list", **options)
    html = split_tag_list_html(template, category_list: TagCategory.categorized_list, headers: false, name_only: true, humanize_tags: true, **options)
    template.tag.span(html, class: classes)
  end

  private

  def typed_tags(name)
    @typed_tags ||= {}
    @typed_tags[name] ||= begin
      @tags.select do |tag|
        categories[tag] == TagCategory.mapping[name]
      end
    end
  end

  def categories
    @categories ||= Tag.categories_for(@tags)
  end

  def counts
    @counts ||= Tag.counts_for(@tags).inject({}) do |hash, x|
      hash[x["name"]] = x["post_count"]
      hash
    end
  end

  def build_list_item(tag, template, name_only: false, humanize_tags: true, show_extra_links: CurrentUser.is_gold?)
    html = ""
    html << %{<li class="category-#{categories[tag]}">}
    current_query = template.params[:tags] || ""

    unless name_only
      if categories[tag] == Tag.categories.artist
        html << %{<a class="wiki-link" href="/artists/show_or_new?name=#{u(tag)}">?</a> }
      else
        html << %{<a class="wiki-link" href="/wiki_pages/show_or_new?title=#{u(tag)}">?</a> }
      end

      if show_extra_links && current_query.present?
        html << %{<a rel="nofollow" href="/posts?tags=#{u(current_query)}+#{u(tag)}" class="search-inc-tag">+</a> }
        html << %{<a rel="nofollow" href="/posts?tags=#{u(current_query)}+-#{u(tag)}" class="search-exl-tag">&ndash;</a> }
      end
    end

    humanized_tag = humanize_tags ? tag.tr("_", " ") : tag
    if categories[tag] == Tag.categories.artist
      itemprop = 'itemprop="author"'
    else
      itemprop = nil
    end
    html << %{<a class="search-tag" #{itemprop} href="/posts?tags=#{u(tag)}">#{h(humanized_tag)}</a> }

    unless name_only
      if counts[tag].to_i >= 10_000
        post_count = "#{counts[tag].to_i / 1_000}k"
      elsif counts[tag].to_i >= 1_000
        post_count = "%.1fk" % (counts[tag].to_f / 1_000)
      else
        post_count = counts[tag].to_s
      end

      is_underused_tag = counts[tag].to_i <= 1 && categories[tag] == Tag.categories.general
      klass = "post-count#{is_underused_tag ? " low-post-count" : ""}"
      title = "New general tag detected. Check the spelling or populate it now."

      html << %{<span class="#{klass}"#{is_underused_tag ? " title='#{title}'" : ""}>#{post_count}</span>}
    end

    html << "</li>"
    html
  end
end
