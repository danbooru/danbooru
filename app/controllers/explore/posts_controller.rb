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
      @posts = ReportbooruService.new.popular_posts(@date)
      respond_with(@posts)
    end

    def searches
      @date, @scale, @min_date, @max_date = parse_date(params)
      @searches = ReportbooruService.new.post_search_rankings(@date)
      respond_with(@searches)
    end

    def missed_searches
      @missed_searches = ReportbooruService.new.missed_search_rankings
      respond_with(@missed_searches)
    end

    private

    def parse_date(params)
      date = params[:date].present? ? Date.parse(params[:date]) : Date.today
      scale = params[:scale].in?(["day", "week", "month"]) ? params[:scale] : "day"
      min_date = date.send("beginning_of_#{scale}")
      max_date = date.send("next_#{scale}").send("beginning_of_#{scale}")

      [date, scale, min_date, max_date]
    end

    def popular_posts(min_date, max_date)
      Post.where(created_at: min_date..max_date).user_tag_match("order:score")
    end

    def curated_posts(min_date, max_date)
      Post.where(created_at: min_date..max_date).user_tag_match("order:curated")
    end
  end
end
