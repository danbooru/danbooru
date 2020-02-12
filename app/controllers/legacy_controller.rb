class LegacyController < ApplicationController
  respond_to :json, :xml

  def posts
    @post_set = PostSets::Post.new(tag_query, params[:page], params[:limit], format: "json")
    @post_set.posts = @post_set.posts.includes(:uploader)
    @posts = @post_set.posts.map(&:legacy_attributes)

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

  def users
    @users = User.limit(100).search(params).paginate(params[:page])
  end

  def tags
    @tags = Tag.limit(100).search(params).paginate(params[:page], :limit => params[:limit])
  end

  def artists
    @artists = Artist.limit(100).search(search_params).paginate(params[:page])
  end

  def unavailable
    render :plain => "this resource is no longer available", :status => 410
  end

  private

  def tag_query
    params[:tags] || (params[:post] && params[:post][:tags])
  end
end
