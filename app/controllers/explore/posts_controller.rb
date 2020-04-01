module Explore
  class PostsController < ApplicationController
    respond_to :html, :xml, :json

    def popular
      @date, @scale, @min_date, @max_date = parse_date(params)

      limit = params.fetch(:limit, CurrentUser.user.per_page)
      @posts = popular_posts(@min_date, @max_date).paginate(params[:page], limit: limit, search_count: false)

      respond_with(@posts)
    end

    def curated
      @date, @scale, @min_date, @max_date = parse_date(params)

      limit = params.fetch(:limit, CurrentUser.user.per_page)
      @posts = curated_posts(@min_date, @max_date).paginate(params[:page], limit: limit, search_count: false)

      respond_with(@posts)
    end

    def viewed
      @date, @scale, @min_date, @max_date = parse_date(params)
      @posts = PostViewCountService.new.popular_posts(@date)
      respond_with(@posts)
    end

    def searches
      @date, @scale, @min_date, @max_date = parse_date(params)
      @search_service = PopularSearchService.new(@date)
    end

    def missed_searches
      @search_service = MissedSearchService.new
    end

    private

    def parse_date(params)
      date = params[:date].present? ? Date.parse(params[:date]) : Time.zone.today
      scale = params[:scale].in?(["day", "week", "month"]) ? params[:scale] : "day"
      min_date = date.send("beginning_of_#{scale}")
      max_date = date.send("next_#{scale}").send("beginning_of_#{scale}")

      [date, scale, min_date, max_date]
    end

    def popular_posts(min_date, max_date)
      Post.where(created_at: min_date..max_date).tag_match("order:score")
    end

    def curated_posts(min_date, max_date)
      Post.where(created_at: min_date..max_date).tag_match("order:curated")
    end
  end
end
