class StaticController < ApplicationController
  def terms_of_service
  end
  
  def accept_terms_of_service
    cookies.permanent[:accepted_tos] = "1"
    redirect_to(params[:url] || posts_path)
  end

  def error
  end
end
