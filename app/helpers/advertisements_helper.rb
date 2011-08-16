module AdvertisementsHelper
  def render_advertisement(ad_type)
		if Danbooru.config.can_user_see_ads?(CurrentUser.user)
	    @advertisement = Advertisement.find(:first, :conditions => ["ad_type = ? AND status = 'active'", ad_type], :order => "random()")
	    content_tag(
	      "div", 
	      link_to_remote(
	        image_tag(
	          @advertisement.image_url, 
	          :alt => "Advertisement", 
	          :width => @advertisement.width, 
	          :height => @advertisement.height
	        ), 
	        advertisement_hit_path(:advertisement_id => @advertisement.id),
	        :style => "margin-bottom: 1em;"
	      )
	    )
		else
			""
		end
  end
  
  def render_rss_advertisement
    if Danbooru.config.can_user_see_ads?(CurrentUser.user)
      render "static/jlist_rss_ads"
    end
  end
end
