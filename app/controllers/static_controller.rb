class StaticController < ApplicationController
  def terms_of_service
  end
  
  def accept_terms_of_service
    cookies.permanent[:accepted_tos] = "1"
    url = params[:url] if params[:url].start_with? '/'
    redirect_to(url || posts_path)
  end

  def error
  end
end
