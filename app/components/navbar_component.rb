# frozen_string_literal: true

class NavbarComponent < ApplicationComponent
  attr_reader :current_user, :params

  delegate :li_link_to, :unread_dmail_indicator, :close_icon, :menu_icon, :main_app, to: :helpers

  def initialize(current_user:, params:)
    super
    @current_user = current_user
    @params = params
  end

  def nav_link_to(*args, **options, &block)
    klass = options.delete(:class)
    url = args.last

    if nav_link_match(params[:controller], url)
      klass = "#{klass} current"
    end

    li_link_to(*args, id_prefix: "nav-", class: klass, **options, &block)
  end

  def nav_link_match(controller, url)
    url =~ case controller
    when "sessions", "users", "admin/users"
      %r{^/(session|users)}

    when "comments"
      %r{^/comments}

    when "notes", "note_versions"
      %r{^/notes}

    when "posts", "uploads", "post_versions", "explore/posts", "moderator/post/dashboards", "favorites"
      %r{^/post}

    when "artists", "artist_versions"
      %r{^/artist}

    when "tags", "tag_aliases", "tag_implications"
      %r{^/tags}

    when "pools", "pool_versions"
      %r{^/pools}

    when "moderator/dashboards"
      %r{^/moderator}

    when "wiki_pages", "wiki_page_versions"
      %r{^/wiki_pages}

    when "forum_topics", "forum_posts"
      %r{^/forum_topics}

    else
      %r{^/static}
    end
  end
end
