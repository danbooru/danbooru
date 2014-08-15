class ApiKeysController < ApplicationController
  before_filter :member_only

  def new
    @api_key = ApiKey.new(:user_id => CurrentUser.user.id)
  end

  def create
    @api_key = ApiKey.generate!(CurrentUser.user)
    
    if @api_key.errors.empty?
      redirect_to user_path(CurrentUser.user), :notice => "API key generated"
    else
      render :action => "new"
    end
  end
end
