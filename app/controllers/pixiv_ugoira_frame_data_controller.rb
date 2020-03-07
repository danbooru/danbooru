class PixivUgoiraFrameDataController < ApplicationController
  respond_to :json, :xml

  def index
    @pixiv_ugoira_frame_data = PixivUgoiraFrameData.paginated_search(params)
    respond_with(@pixiv_ugoira_frame_data)
  end
end
