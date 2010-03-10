class PostsController < ApplicationController
  before_filter :member_only, :except => [:show, :index]
  after_filter :save_recent_tags, :only => [:create, :update]
  
  def index
  end
  
  def show
  end
  
  def update
  end
  
  def revert
  end
end
