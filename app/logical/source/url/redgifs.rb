# frozen_string_literal: true

# @see Source::Extractor::Redgifs
class Source::URL::Redgifs < Source::URL
  attr_reader :gif_id, :username, :file_url

  def self.match?(url)
    url.domain == "redgifs.com"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://thumbs44.redgifs.com/ThunderousVerifiableScoter-mobile.jpg?expires=1715806200&signature=v2:b774b57f548f8171862b560d007f05b383530e7f167dde99e81b605f158131a5&for=198.54.135&hash=7011125643 (sample thumbnail)
    # https://thumbs44.redgifs.com/ThunderousVerifiableScoter-mobile.mp4?expires=1715806200&signature=v2:41ad91e3b6fa4837191697da448ff9fa0d5386950660da2913faa00c4b029191&for=198.54.135&hash=7011125643 (sample video)
    # https://thumbs44.redgifs.com/ThunderousVerifiableScoter.mp4?expires=1715806200&signature=v2:5ade027d51718e4482c586504aeb4269be068d0c306d66895c13b1cd971c87ec (full)
    # https://thumbs46.redgifs.com/DiligentFluidBichonfrise-large.jpg?expires=1715896200&signature=v2:bda783db2b1afe2b87f83778eb5fd8cd14cda0f594079c959e24cd7be2edc007 (full non-video)
    in /thumbs/, "redgifs.com", _
      @gif_id = filename.split("-").first.downcase
      @file_url = without_params(:for, :hash).to_s

    # https://www.redgifs.com/watch/thunderousverifiablescoter
    # https://www.redgifs.com/ifr/thunderousverifiablescoter
    in _, "redgifs.com", ("watch" | "ifr"), gif_id
      @gif_id = gif_id.downcase

    # https://i.redgifs.com/i/diligentfluidbichonfrise.jpg (not an image, redirects to https://www.redgifs.com/watch/diligentfluidbichonfrise)
    in "i", "redgifs.com", "i", _
      @gif_id = filename.downcase

    # https://api.redgifs.com/v2/gifs/thunderousverifiablescoter?views=yes&users=yes&niches=yes
    # https://api.redgifs.com/v2/gifs/understatedgranularshrew/files/UnderstatedGranularShrew.mp4
    # https://api.redgifs.com/v2/gifs/understatedgranularshrew/files/UnderstatedGranularShrew-poster.jpg
    in "api", "redgifs.com", "v2", "gifs", gif_id, *rest
      @gif_id = gif_id.downcase

    # https://redgifs.com/users/LazyProcrastinator ->  https://www.redgifs.com/users/lazyprocrastinator
    # https://redgifs.com/users/LazyProcrastinator/collections
    in _, "redgifs.com", "users", username, *rest
      @username = username.downcase

    # https://www.redgifs.com/gifs/animation
    # https://userpic.redgifs.com/9/25/9258da4aee0dfd4abe366f60f2c43ce4.png
    else
      nil
    end
  end

  def image_url?
    # https://thumbs44.redgifs.com/ThunderousVerifiableScoter.mp4
    # https://userpic.redgifs.com/9/25/9258da4aee0dfd4abe366f60f2c43ce4.png
    # non-image: https://i.redgifs.com/i/diligentfluidbichonfrise.jpg
    # non-image: https://api.redgifs.com/v2/gifs/understatedgranularshrew/files/UnderstatedGranularShrew.mp4
    subdomain in /thumbs/ | "userpic"
  end

  def page_url
    "https://www.redgifs.com/watch/#{gif_id}" if gif_id.present?
  end

  def profile_url
    "https://www.redgifs.com/users/#{username}" if username.present?
  end
end
