class IqdbController < ApplicationController
  def similar_by_source
    @download = Iqdb::Download.new(params[:source])
    @download.download_from_source
    @download.find_similar
    render :layout => false
  end
end
