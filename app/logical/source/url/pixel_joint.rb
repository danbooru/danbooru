# frozen_string_literal: true

# @see Source::Extractor::PixelJoint
class Source::URL::PixelJoint < Source::URL
  site "Pixel Joint", url: "https://pixeljoint.com", domains: %w[pixeljoint.com]

  attr_reader :work_id, :user_id

  def self.match?(url)
    url.domain == "pixeljoint.com"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://pixeljoint.com/files/icons/full/cat__r16042437891.png (full image)
    # https://pixeljoint.com/files/icons/cat_icon.png (thumbnail)
    # https://pixeljoint.com/files/icons/icon__r15732437891.png (avatar)
    #
    # Thumbnails are uploaded separately from the full image and have unrelated filenames, so they can't be converted
    # to the full image.
    in _, "pixeljoint.com", "files", *rest
      nil

    # https://pixeljoint.com/pixelart/165655.htm
    in _, "pixeljoint.com", "pixelart", /\A(\d+)\.htm\z/
      @work_id = $1

    # https://pixeljoint.com/p/243789.htm
    in _, "pixeljoint.com", "p", /\A(\d+)\.htm\z/
      @user_id = $1

    # https://pixeljoint.com/pixels/profile.asp?id=243789
    in _, "pixeljoint.com", "pixels", "profile.asp" if params[:id].to_s.match?(/\A\d+\z/)
      @user_id = params[:id]

    # https://pixeljoint.com/pixelart/2003/Miscellaneous.htm (category)
    else
      nil
    end
  end

  # Avatars are also in /files/icons/, but they can't be told apart from thumbnails.
  def image_sample?
    image_url? && !path.start_with?("/files/icons/full/")
  end

  def page_url
    "https://pixeljoint.com/pixelart/#{work_id}.htm" if work_id.present?
  end

  def profile_url
    "https://pixeljoint.com/p/#{user_id}.htm" if user_id.present?
  end
end
