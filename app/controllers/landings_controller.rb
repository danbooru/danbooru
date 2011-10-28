class LandingsController < ApplicationController
  def show
    @explorer = PopularPostExplorer.new
    render :layout => "blank"
  end
end
