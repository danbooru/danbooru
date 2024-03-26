# frozen_string_literal: true

module ComponentsHelper
  def post_preview(post, fit: :fixed, **options, &block)
    render PostPreviewComponent.new(post: post, fit: fit, **options), &block
  end

  # Render a set of posts as thumbnail gallery.
  #
  # @param posts [ActiveRecord::Relation<Post>, Array<Post>] A set of posts.
  # @param options [Hash] A hash of options for the PostGalleryComponent and PostPreviewComponent.
  def render_post_gallery(posts, **options, &block)
    posts = posts.includes(:media_asset) if posts.is_a?(ActiveRecord::Relation)

    render(PostGalleryComponent.new(**options)) do |gallery|
      posts.each do |post|
        gallery.with_post(post: post, size: gallery.size, **options)
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

  # A horizontal tag list, with tags grouped by category. Used in post
  # tooltips, on the comments index, and in the modqueue.
  def render_inline_tag_list(post, **options)
    render InlineTagListComponent.new(tags: post.tags, **options)
  end

  def render_inline_tag_list_from_names(tag_names, **options)
    tags = InlineTagListComponent.tags_from_names(tag_names)
    render InlineTagListComponent.new(tags: tags, **options)
  end

  # A vertical tag list, with tags split into categories. Used on post show pages.
  def render_categorized_tag_list(post, **options)
    render CategorizedTagListComponent.new(tags: post.tags, **options)
  end

  # The <link rel="next"> / <link rel="prev"> links in the <meta> element of the <head>.
  def render_meta_links(records)
    render MetaLinksComponent.new(records: records, params: params)
  rescue ActiveRecord::StatementInvalid
    # Swallow any exceptions when loading records so that the page load doesn't fail.
  end

  def render_tag_change_notice(tag:, current_user:)
    render TagChangeNoticeComponent.new(tag: tag, current_user: current_user)
  end

  def numbered_paginator(records)
    if records.paginator_mode == :numbered
      render NumberedPaginatorComponent.new(records: records, params: params)
    else
      render SequentialPaginatorComponent.new(records: records, params: params)
    end
  end

  def help_tooltip(content = nil, icon: help_icon, **options, &block)
    content = yield if block_given?
    render HelpTooltipComponent.new(icon, content, **options)
  end
end
