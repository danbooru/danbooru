module Explore
  class PostsController < ApplicationController
    respond_to :html, :xml, :json
    before_action :set_date, only: [:searches, :viewed]

    def popular
      @date = params[:date] ? Date.parse(params[:date]) : Date.today
      @scale = params[:scale]
      @scale = "day" unless @scale.in?(["day", "week", "month"])

      limit = params.fetch(:limit, CurrentUser.user.per_page)
      @posts = popular_posts(@date, @scale).paginate(params[:page], limit: limit)
      respond_with(@posts)
    end

    def viewed
      @posts = PostViewCountService.new.popular_posts(@date)
      respond_with(@posts)
    end

    def searches
      @search_service = PopularSearchService.new(@date)
    end

    def missed_searches
      @search_service = MissedSearchService.new
    end

    def intro
      @presenter = IntroPresenter.new
      render :layout => "blank"
    end

    private

    def set_date
      @date = params[:date] ? Date.parse(params[:date]) : Date.today
    end

    def popular_posts(date, scale)
      if scale == "day"
        Post.tag_match("date:#{date} order:score")
      else
        min_date = date.send("beginning_of_#{scale}").to_date.to_s
        max_date = date.send("end_of_#{scale}").to_date.to_s
        search = "date:#{min_date}..#{max_date} order:score"
        Post.tag_match(search)
      end
    end
  end
end
