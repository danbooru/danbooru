class StaticController < ApplicationController
  before_filter :check_desktop_mode, only: :site_map

  def terms_of_service
  end
  
  def accept_terms_of_service
    cookies.permanent[:accepted_tos] = "1"
    url = params[:url] if params[:url] && params[:url].start_with?("/")
    redirect_to(url || posts_path)
  end

  def not_found
    render text: "not found", status: :not_found
  end

  def error
  end

  def site_map
  end

  private

  def check_desktop_mode
    if params[:dm]
      cookies[:dm] = "1"
      redirect_to :back
      return false
    end
  end
  
end
