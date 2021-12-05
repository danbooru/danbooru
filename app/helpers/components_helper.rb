module ComponentsHelper
  def post_preview(post, fit: :fixed, **options)
    render PostPreviewComponent.new(post: post, fit: fit, **options)
  end

  # Render a set of posts as thumbnail gallery.
  #
  # @param posts [ActiveRecord::Relation<Post>, Array<Post>] A set of posts.
  # @param options [Hash] A hash of options for the PostGalleryComponent and PostPreviewComponent.
  def render_post_gallery(posts, **options, &block)
    posts = posts.includes(:media_asset) if posts.is_a?(ActiveRecord::Relation)

    render(PostGalleryComponent.new(**options)) do |gallery|
      posts.each do |post|
        gallery.post(post: post, size: gallery.size, **options)
      end

      if block_given?
        yield(gallery, posts)
      end
    end
  end

  def render_comment(comment, current_user:, **options)
    render CommentComponent.new(comment: comment, current_user: current_user, **options)
  end

  def render_comment_section(post, **options)
    render CommentSectionComponent.new(post: post, **options)
  end

  def render_post_votes(post, **options)
    render PostVotesComponent.new(post: post, **options)
  end

  def render_post_votes_tooltip(post, **options)
    render PostVotesTooltipComponent.new(post: post, **options)
  end

  def render_comment_votes_tooltip(comment, **options)
    render CommentVotesTooltipComponent.new(comment: comment, **options)
  end

  def render_favorites_tooltip(post, **options)
    render FavoritesTooltipComponent.new(post: post, **options)
  end

  def render_post_navbar(post, **options)
    render PostNavbarComponent.new(post: post, **options)
  end

  def render_source_data(source, **options)
    render SourceDataComponent.new(source: source, **options)
  end

  # A simple vertical tag list with no post counts. Used in related tags.
  def render_simple_tag_list(tag_names, **options)
    tags = TagListComponent.tags_from_names(tag_names)
    render TagListComponent.new(tags: tags, **options).with_variant(:simple)
  end

  # A horizontal tag list, with tags grouped by category. Used in post
  # tooltips, on the comments index, and in the modqueue.
  def render_inline_tag_list(post, **options)
    render TagListComponent.new(tags: post.tags, **options).with_variant(:inline)
  end

  def render_inline_tag_list_from_names(tag_names, **options)
    tags = TagListComponent.tags_from_names(tag_names)
    render TagListComponent.new(tags: tags, **options).with_variant(:inline)
  end

  # A vertical tag list, with tags split into categories. Used on post show pages.
  def render_categorized_tag_list(post, **options)
    render TagListComponent.new(tags: post.tags, **options).with_variant(:categorized)
  end

  # A vertical tag list, used in the post index sidebar.
  def render_search_tag_list(tag_names, **options)
    tags = TagListComponent.tags_from_names(tag_names)
    render TagListComponent.new(tags: tags, **options).with_variant(:search)
  end

  # The <link rel="next"> / <link rel="prev"> links in the <meta> element of the <head>.
  def render_meta_links(records)
    render PaginatorComponent.new(records: records, params: params).with_variant(:meta_links)
  end

  def numbered_paginator(records)
    paginator = PaginatorComponent.new(records: records, params: params)

    if paginator.use_sequential_paginator?
      render paginator.with_variant(:sequential)
    else
      render paginator.with_variant(:numbered)
    end
  end
end
