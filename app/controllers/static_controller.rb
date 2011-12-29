class StaticController < ApplicationController
  def jquery_test
  end
  
  def terms_of_service
    render :layout => "blank"
  end
end
