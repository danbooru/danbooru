# frozen_string_literal: true

class LegacyController < ApplicationController
  respond_to :json, :xml

  def posts
    @post_set = PostSets::Post.new(tag_query, params[:page], params[:limit], format: "json")
    @posts = @post_set.posts.includes(:uploader).map(&:legacy_attributes)
    authorize @posts, policy_class: LegacyControllerPolicy

    respond_with(@posts) do |format|
      format.xml do
        xml = ::Builder::XmlMarkup.new(indent: 2)
        xml.instruct!
        xml.posts do
          @posts.each { |attrs| xml.post(attrs) }
        end
        render xml: xml.target!
      end
    end
  end

  def tags
    @tags = Tag.limit(100).search(params, CurrentUser.user).paginate(params[:page], :limit => params[:limit])
    authorize @tags, policy_class: LegacyControllerPolicy
  end

  def unavailable
    render :plain => "this resource is no longer available", :status => 410
  end

  private

  def tag_query
    params[:tags] || (params[:post] && params[:post][:tags])
  end
end
