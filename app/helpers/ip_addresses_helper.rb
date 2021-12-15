# frozen_string_literal: true

module IpAddressesHelper
  # https://www.bing.com/maps/embed-a-map
  # https://docs.microsoft.com/en-us/bingmaps/articles/create-a-custom-map-url
  def embedded_map(lat, long, width, height, zoom: 10)
    tag.iframe(
      width: width,
      height: height,
      frameborder: 0,
      allowfullscreen: true,
      src: "https://www.bing.com/maps/embed?w=#{width}&h=#{height}&cp=#{lat}~#{long}&lvl=#{zoom}"
    )
  end
end
