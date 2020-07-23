class StaticController < ApplicationController
  def privacy_policy
  end

  def terms_of_service
  end

  def not_found
    render plain: "not found", status: :not_found
  end

  def error
  end

  def dtext_help
    redirect_to wiki_page_path("help:dtext") unless request.format.js?
  end

  def opensearch
  end

  def site_map
  end

  def sitemap_index
    @sitemap = params[:sitemap]
    @limit = params.fetch(:limit, 10000).to_i

    case @sitemap
    when "artists"
      @relation = Artist.undeleted
      @search = { is_deleted: "false" }
    when "forum_topics"
      @relation = ForumTopic.undeleted
      @search = { is_deleted: "false" }
    when "pools"
      @relation = Pool.undeleted
      @search = { is_deleted: "false" }
    when "posts"
      @relation = Post.order(id: :asc)
      @serach = {}
    when "tags"
      @relation = Tag.nonempty
      @search = {}
    when "users"
      @relation = User.all
      @search = {}
    when "wiki_pages"
      @relation = WikiPage.undeleted
      @search = { is_deleted: "false" }
    else
      raise NotImplementedError
    end
  end
end
