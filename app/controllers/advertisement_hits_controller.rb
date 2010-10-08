class AdvertisementHitsController < ApplicationController
  def create
    advertisement = Advertisement.find(params[:id])
    advertisement.hits.create(:ip_addr => request.remote_ip)
		redirect_to advertisement.referral_url
  end

protected
  def set_title
    @page_title = Danbooru.config.app_name + "/advertisements"
  end    
end
