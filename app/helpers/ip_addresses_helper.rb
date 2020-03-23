module IpAddressesHelper
  def embedded_google_map(location, width, height, api_key: Danbooru.config.google_maps_api_key)
    tag.iframe(
      width: width,
      height: height,
      frameborder: 0,
      allowfullscreen: true,
      src: "https://www.google.com/maps/embed/v1/search?q=#{location}&key=#{api_key}"
    )
  end
end
